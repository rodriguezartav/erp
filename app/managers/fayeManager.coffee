Spine = require('spine')
PedidoPreparado  =  require("models/socketModels/pedidoPreparado")
NotificationManager = require("managers/notificationManager")


class FayeManager
  
  constructor: ->
    @connect() if navigator.onLine

  connect: =>
    @handshake()
    Spine.bind "login_complete" , @subscribe

  handshake: =>
    @fayeClient = new Faye.Client '/faye' , timeout: 300 , retry: 20

  subscribe: =>
    @fayeClient.subscribe "/topic/Pedido__c" , (message) =>
      if PedidoPreparado.updateFromSocket(message)
        Spine.notifications.showNotification( "Aprobacion de Pedidos" , "Hay Pedidos Pendientes por Aprobar" )

    for m in Spine.socketModels   
      if m.autoPush
        className = m.className 

        @fayeClient.subscribe "/topic/#{className}__c" , m.updateFromSocket



module.exports = FayeManager