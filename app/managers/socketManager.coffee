Spine = require('spine')
PedidoPreparado  =  require("models/socketModels/pedidoPreparado")
Cliente = require("models/cliente")

class SocketManager
  
  constructor: (@url) ->
    @connect() if navigator.onLine

  connect: =>
    @handshake()
    Spine.bind "login_complete" , @subscribe

  handshake: =>
    @pusher = new Pusher(Spine.pusherKey) 
    
    @salesforceConnectionChannel  = @pusher.subscribe('salesforce_connection_information')
    
    @salesforceConnectionChannel.bind 'connect', (data) ->
      #Spine.trigger "show_lightbox" , "showWarning" , error : "Se conecto al servicio de actualizacion"

    @salesforceConnectionChannel.bind 'error', (data) ->
      #Spine.trigger "show_lightbox" , "showWarning" , error : "Se desconecto al servicio de actualizacion, no recibira actualizaciones"

  subscribe: =>
    @channel = @pusher.subscribe('salesforce_data_push')

    @channel.bind "Pedido__c" , (message) =>
      results = PedidoPreparado.updateFromSocket(message)
      if results  != false
        if Spine.session.hasPerfiles(['Venededor','Platform System Admin','Ejecutivo Ventas' , 'Encargado de Ventas']) and PedidoPreparado.lastNotificationEstado == 'Facturado'
          Spine.notifications.showNotification( "Aprobacion de Pedidos" , "Aprobado Pedido de " + Cliente.find(PedidoPreparado.lastNotificationCliente)?.Name )
        
        else if Spine.session.hasPerfiles(['Platform System Admin','Ejecutivo Credito']) and PedidoPreparado.lastNotificationEstado == 'Pendiente'
          Spine.notifications.showNotification( "Aprobacion de Pedidos" , "Hay Pedidos Pendientes por Aprobar de " + Cliente.find(PedidoPreparado.lastNotificationCliente)?.Name )

    for m in Spine.socketModels   
      if m.autoPush
        className = m.className 
        @channel.bind "#{className}__c" , m.updateFromSocket

module.exports = SocketManager