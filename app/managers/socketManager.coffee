Spine = require('spine')
PedidoPreparado  =  require("models/socketModels/pedidoPreparado")
FacturaPreparada  =  require("models/socketModels/facturaPreparada")
Saldo  =  require("models/socketModels/saldo")
Notificacion = require "models/notificacion"
Cliente  =  require("models/cliente")
Producto  =  require("models/producto")
User  =  require("models/user")

# There are 1 channel/s
# public_salesforce-silent-push
#
#
#

class SocketManager
  
  constructor: (@url) ->
    @connect() if navigator.onLine
    Spine.socketManager = @

  connect: =>
    @handshake()
    Spine.bind "login_complete" , @subscribe

  handshake: =>
    try
      Pusher.channel_auth_endpoint = "/pusherAuth" #Spine.pusherKeys.authUrl
      @pusher = new Pusher(Spine.pusherKeys.restKey) 

    catch error
      Spine.trigger "show_lightbox" , "show-warning" , error: "No se puedo conectar al Notificador , intente reiniciar cuando haya internet"

  subscribe: =>
    return false if !@pusher
    user =
      id:     Spine.session.user.Id
      name:   Spine.session.user.Name
      title:  Spine.session.user.Profile__c
      photo:  Spine.session.user.SmallPhotoUrl
    Spine.setCookie "user_details" , JSON.stringify user
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
      console.log members

    @presence.bind 'pusher:member_added' , (member) =>
      console.log member

    @presence.bind 'pusher:member_removed' , (member) =>
      console.log member



  pushToProfile: (profile, text ) =>
    data = { user: Spine.session.userId , text: text}
    @private_erp_profiles.trigger("client-#{profile}" , data );

  pushToFeed: ( text ) =>
    data = { user: Spine.session.userId , text: text}
    @private_erp_profiles.trigger("client-feed" , data );

  profileEvents: =>
    @private_erp_profiles = @pusher.subscribe('private-erp_profiles')

    @private_erp_profiles.bind "client-#{Spine.session.user.Perfil__c}" , (message) =>
      user = User.find message.user
      Notificacion.createForPerfil( user , message.text , true )

    @private_erp_profiles.bind "client-feed" , (message) =>
      user = User.find message.user
      Notificacion.createForFeed( user , message.text )

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