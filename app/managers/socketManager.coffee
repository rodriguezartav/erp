Spine = require('spine')
PedidoPreparado  =  require("models/socketModels/pedidoPreparado")
FacturaPreparada  =  require("models/socketModels/facturaPreparada")
FacturaEntregada  =  require("models/socketModels/facturaEntregada")

Saldo  =  require("models/socketModels/saldo")
Notificacion = require "models/notificacion"
Cliente  =  require("models/cliente")
Producto  =  require("models/producto")
User  =  require("models/user")
Feed = require "models/notifications/feed"
Task = require "models/notifications/task"


class SocketManager
  
  constructor: (@url) ->
    @connect() if navigator.onLine
    Spine.socketManager = @

  connect: =>
    @handshake()
    Spine.bind "login_complete" , @subscribe

  handshake: =>
    try
      Pusher.channel_auth_endpoint = Spine.pusherKeys.authUrl
      @pusher = new Pusher(Spine.pusherKeys.restKey) 

    catch error
      Spine.trigger "show_lightbox" , "show-warning" , error: "No se puedo conectar al Notificador , intente reiniciar cuando haya internet"

  subscribe: =>
    return false if !@pusher
    user =
      id:     Spine.session.user.id
      name:   Spine.session.user.Name
      title:  Spine.session.user.Profile
      photo:  Spine.session.user.SmallPhotoUrl
      
    for pusher in Pusher.instances
      pusher.options=
        auth:
          params:
            user_details: JSON.stringify user
    @salesforceSync()
    @presenceEvents()
    @profileEvents()
    @appEvents()

  salesforceSync: =>
    @public_salesforce = @pusher.subscribe('public_salesforce-silent-push')
    for model in Spine.socketModels
      model.registerForUpdate @public_salesforce

  presenceEvents: =>
    @presence = @pusher.subscribe('presence-erp')

    @presence.bind 'pusher:subscription_succeeded' , (members) =>
      for index,member of members._members_map
        people = User.exists member.id
        if people
          people.LastUpdate = new Date();
          people.Online = true
          people.save()
      
    @presence.bind 'pusher:member_added' , (member) =>
      people = User.exists member.id
      if people
        people.Online = true
        people.LastUpdate = new Date();
        people.Status = "Ingreso al Sistema"
        people.save()        
      
    
    @presence.bind 'pusher:member_removed' , (member) =>

      people = User.exists member.id
      if people
        people.Online = false
        people.Status = 'Salio del Sistema'
        people.save()        

  pushToProfile: (profile, text ) =>
    data = { user: Spine.session.userId , text: text}
    @private_erp_profiles?.trigger("client-#{profile}" , data );

  pushToFeed: ( text ) =>
    data = { user: Spine.session.userId , text: text}
    @private_erp_profiles?.trigger("client-feed" , data );

  profileEvents: =>
    @private_erp_profiles = @pusher.subscribe('private-erp_profiles')
    
    @private_erp_profiles.bind "client-#{Spine.session.user.Perfil}" , (message) =>
      user = User.find message.user
      Task.createForPerfil( user , message.text , true )

    @private_erp_profiles.bind "client-feed" , (message) =>
      user = User.find message.user
      feed = Feed.createForFeed( user , message.text )

  appEvents: ->
    @public_app_actions = @pusher.subscribe('public_app_actions')

    @public_app_actions.bind "server-refresh" , (message) =>
      window.location.reload()

    @public_app_actions.bind "server-actualizar" , (message) =>
      Spine.trigger "actualizar_ahora"

    @public_app_actions.bind "server-reset" , (message) =>
      Spine.trigger "master_reset"

  push: (eventName, data ) =>
    @ascChannel.trigger("client-#{eventName}", data );

  ascEvents: =>
    @ascChannel  = @pusher.subscribe('private-asc_data_push')

    @ascChannel.bind "client-custumer_registration" , (message) ->
      Notificacion.createFromMessage message , "#{message.user.name} de #{message.user.empresa} necesita una autorizacion." , true

    @ascChannel.bind "client-custumer_login" , (message) ->
      Notificacion.createFromMessage message , "#{message.user.name} de #{message.user.empresa} ingreso al sistema" , false

    @ascChannel.bind "client-custumer_aproval" , (message) ->
      if Spine.session.hasPerfiles(['Platform System Admin','Ejecutivo Credito'])
        Notificacion.createFromMessage message , "Autorizado y enviado PIN #{message.user.name} de #{message.user.empresa}" , true

module.exports = SocketManager