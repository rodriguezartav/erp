Spine = require('spine')
PedidoPreparado  =  require("models/socketModels/pedidoPreparado")

class SocketManager
  
  constructor: (@url) ->
    @connect() if navigator.onLine

  connect: =>
    @handshake()
    Spine.bind "login_complete" , @subscribe

  handshake: =>
    console.log @url
    @socket = io.connect(@url);
    @socket.on "connectionInfo" , (message) ->
      console.log message
      
  #  @fayeClient = new Faye.Client "/faye" , timeout: 300 , retry: 20
  #  console.log @fayeClient

  subscribe: =>
    
    @socket.on "/topic/Pedido__c" , (message) =>
      if PedidoPreparado.updateFromSocket(message)
        Spine.notifications.showNotification( "Aprobacion de Pedidos" , "Hay Pedidos Pendientes por Aprobar" )

    for m in Spine.socketModels   
      if m.autoPush
        className = m.className 

        @socket.on "/topic/#{className}__c" , m.updateFromSocket



module.exports = SocketManager