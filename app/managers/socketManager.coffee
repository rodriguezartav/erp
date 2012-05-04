Spine = require('spine')
PedidoPreparado  =  require("models/socketModels/pedidoPreparado")

class SocketManager
  
  constructor: (@url) ->
    @connect() if navigator.onLine

  connect: =>
    @handshake()
    Spine.bind "login_complete" , @subscribe

  handshake: =>
    @pusher = new Pusher('a8cfc9203fbabab7e67f') 
    
    @salesforceConnectionChannel  = @pusher.subscribe('salesforce_connection_information')
    
    @salesforceConnectionChannel.bind 'connect', (data) ->
      Spine.trigger "show_lightbox" , "showWarning" , error : "Se conecto al servicio de actualizacion"

    @salesforceConnectionChannel.bind 'error', (data) ->
      Spine.trigger "show_lightbox" , "showWarning" , error : "Se desconecto al servicio de actualizacion, no recibira actualizaciones"

  subscribe: =>
    @channel = @pusher.subscribe('salesforce_data_push')

    @channel.bind "Pedido__c" , (message) =>
      if PedidoPreparado.updateFromSocket(message)
        Spine.notifications.showNotification( "Aprobacion de Pedidos" , "Hay Pedidos Pendientes por Aprobar" )

    for m in Spine.socketModels   
      if m.autoPush
        className = m.className 
        @channel.bind "#{className}__c" , m.updateFromSocket


module.exports = SocketManager