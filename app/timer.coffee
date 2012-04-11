Spine = require('spine')
Pedido = require('models/pedido')
DocumentoPreparado = require('models/sobjects/documentoPreparado')

Lightbox = require("controllers/lightbox")


class Timer

  @registerTimers: =>
    
    Spine.followTimeoutUI= =>
      if !Spine.timeoutUI
        Spine.timeoutUI =  window.setInterval(Spine.blockUI , 1000*60*5) 

    Spine.blockUI= =>
      Spine.trigger "show_lightbox" , "block"

    #Sets Timmer and Makes First Call
    Spine.followPedidosPendientes= =>
      window.clearInterval(Spine.checkPedidosPendientes) if Spine.followPedidosPendientesTimer
      Spine.checkPedidosPendientes()
      Spine.followPedidosPendientesTimer =  window.setInterval(Spine.checkPedidosPendientes , 1000*60*2) 

    Spine.checkPedidosPendientes= =>
      Pedido.query({estado: "Nuevo"})


    #Sets Timmer and Makes First Call
    Spine.followDocumentosPreparados= =>
      window.clearInterval(Spine.FollowDocumentosPreparadosTimer) if Spine.FollowDocumentosPreparadosTimer
      Spine.checkDocumentosPreparados()
      Spine.FollowDocumentosPreparadosTimer =  window.setInterval(Spine.checkDocumentosPreparados , 1000*60*2) 

    Spine.checkDocumentosPreparados= =>
      DocumentoPreparado.query({})



    Spine.followNavigatorStatus= =>
      Spine.followNavigatorStatusTimer = window.setInterval Spine.checkStatus , 10000 if !Spine.followNavigatorStatusTimer

    Spine.checkStatus= ->
      change = false
      if navigator.onLine and Spine.status != "online"
        Spine.status = "online"
        change=true

      else if !navigator.onLine and Spine.status != "offline"
        Spine.status = "offline"
        change=true

      if change
        Spine.trigger "status_changed" , Spine.status
    


module.exports = Timer

