Spine = require('spine')
PedidoPreparado  =  require("models/socketModels/pedidoPreparado")
FacturaPreparada  =  require("models/socketModels/facturaPreparada")
Saldo  =  require("models/socketModels/saldo")
Notificacion = require "models/notificacion"
Cliente  =  require("models/cliente")
Producto  =  require("models/producto")

class SocketManager
  
  constructor: (@url) ->
    @connect() if navigator.onLine
    Spine.socketManager = @

  connect: =>
    @handshake()
    Spine.bind "login_complete" , @subscribe

  handshake: =>
    try
      Pusher.channel_auth_endpoint = 'https://erp.rodcocr.com/pusherAuth';
      @pusher = new Pusher(Spine.pusherKey) 

    catch error
      Spine.trigger "show_lightbox" , "show-warning" , error: "No se puedo conectar al Notificador , intente reiniciar cuando haya internet"

  push: (eventName, data ) =>
    triggered = @ascChannel.trigger("client-#{eventName}", data );

  subscribe: =>
    return false if !@pusher
    @channel = @pusher.subscribe('salesforce_data_push')
    @ascChannel  = @pusher.subscribe('private-asc_data_push')

    @ascChannel.bind "client-custumer_registration" , (message) ->
      Notificacion.createFromMessage message , "#{message.user.name} de #{message.user.empresa} necesita una autorizacion." , true

    @ascChannel.bind "client-custumer_login" , (message) ->
      Notificacion.createFromMessage message , "#{message.user.name} de #{message.user.empresa} ingreso al sistema" , false

    @ascChannel.bind "client-custumer_aproval" , (message) ->
      if Spine.session.hasPerfiles(['Platform System Admin','Ejecutivo Credito'])
        Notificacion.createFromMessage message , "Autorizado y enviado PIN #{message.user.name} de #{message.user.empresa}" , true

    @channel.bind "Clientes" , (message) =>
      results = Cliente.updateFromSocket(message)

    @channel.bind "Saldos" , (message) =>
      results = Saldo.updateFromSocket(message)
      Saldo.onQuerySuccess()

    @channel.bind "Productos" , (message) =>
      results = Producto.updateFromSocket(message)

    @channel.bind "PedidoPreparado" , (message) =>
      results = PedidoPreparado.updateFromSocket(message)
      if Spine.session.hasPerfiles(['Platform System Admin','Ejecutivo Credito'])
        cliente = Cliente.exists results?[0].Cliente
        Notificacion.createFromMessage message , "Prepare un pedido de #{cliente?.Name}" , true

    @channel.bind "PedidoAprobado" , (message) =>
      results = PedidoPreparado.updateFromSocket(message)

    @channel.bind "FacturaPreparada" , (message) =>
      results = FacturaPreparada.updateFromSocket(message)
      return false if !results or results?[0].IsContado or !Spine.session.hasPerfiles(['Platform System Admin','Ejecutivo Ventas' ])
      console.log results
      cliente = Cliente.exists results?[0].Cliente
      Notificacion.createFromMessage message , "Pueden imprimir pedido de #{cliente.Name}" , true

    @channel.bind "FacturaImpresa" , (message) =>
      results = FacturaPreparada.updateFromSocket(message)

module.exports = SocketManager