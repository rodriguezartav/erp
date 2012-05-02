Spine = require('spine')

Cliente   =  require("models/cliente")
Producto  =  require("models/producto")

class FayeManager
  
  constructor: ->
    @connect() if navigator.onLine

  connect: =>
    @fayeClient = new Faye.Client '/faye' , timeout: 300 , retry: 20
    @subscribe()

  subscribe: =>
    @clienteSubscription = @fayeClient.subscribe '/topic/Cliente__c' , (message) ->
      Cliente.updateFromSocket(message)

    @productoSubscription = @fayeClient.subscribe '/topic/Producto__c' , (message) ->
      Producto.updateFromSocket(message)

module.exports = FayeManager