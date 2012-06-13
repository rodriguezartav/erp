Spine = require('spine')
PedidoPreparado  =  require("models/socketModels/pedidoPreparado")
FacturaPreparada  =  require("models/socketModels/facturaPreparada")
Saldo  =  require("models/socketModels/saldo")

Cliente  =  require("models/cliente")


class SocketManager
  
  constructor: (@url) ->
    @connect() if navigator.onLine

  connect: =>
    @handshake()
    Spine.bind "login_complete" , @subscribe

  handshake: =>
    try
      @pusher = new Pusher(Spine.pusherKey) 
    
      @salesforceConnectionChannel  = @pusher.subscribe('salesforce_connection_information')
    
      @salesforceConnectionChannel.bind 'connect', (data) ->
        #Spine.trigger "show_lightbox" , "showWarning" , error : "Se conecto al servicio de actualizacion"

      @salesforceConnectionChannel.bind 'error', (data) ->
        #Spine.trigger "show_lightbox" , "showWarning" , error : "Se desconecto al servicio de actualizacion, no recibira actualizaciones"
    
    catch error
      Spine.trigger "show_lightbox" , "show-warning" , error: "No se puedo conectar al Notificador , intente reiniciar cuando haya internet"
    
  
  subscribe: =>
    return false if !@pusher
    @channel = @pusher.subscribe('salesforce_data_push')

    @channel.bind "AllDocumentos" , (message) =>
      results = FacturaPreparada.updateFromSocket(message)
      results = Saldo.updateFromSocket(message)

      if results  != false
        if Spine.session.hasPerfiles(['Vendedor','Platform System Admin','Ejecutivo Ventas' , 'Encargado de Ventas'])
          Spine.notifications.showNotification( "Impresion de Facturas" , "Impresa Factura de " + Cliente.find(FacturaPreparada.lastNotificationCliente)?.Name )

    @channel.bind "AllPedidos" , (message) =>
      console.log message
      results = PedidoPreparado.updateFromSocket(message)
      if results  != false
        if Spine.session.hasPerfiles(['Vendedor','Platform System Admin','Ejecutivo Ventas' , 'Encargado de Ventas']) and PedidoPreparado.lastNotificationEstado == 'Facturado'
          Spine.notifications.showNotification( "Aprobacion de Pedidos" , "Aprobado Pedido de " + Cliente.find(PedidoPreparado.lastNotificationCliente)?.Name )
        
        else if Spine.session.hasPerfiles(['Platform System Admin','Ejecutivo Credito']) and PedidoPreparado.lastNotificationEstado == 'Pendiente'
          Spine.notifications.showNotification( "Aprobacion de Pedidos" , "Hay Pedidos Pendientes por Aprobar de " + Cliente.find(PedidoPreparado.lastNotificationCliente)?.Name )

module.exports = SocketManager