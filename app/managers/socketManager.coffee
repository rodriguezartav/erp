Spine = require('spine')
PedidoPreparado  =  require("models/socketModels/pedidoPreparado")
FacturaPreparada  =  require("models/socketModels/facturaPreparada")
Saldo  =  require("models/socketModels/saldo")

Cliente  =  require("models/cliente")
Producto  =  require("models/producto")

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

    @channel.bind "Clientes" , (message) =>
      #console.log "Updating Clientes"
      #console.log message
      results = Cliente.updateFromSocket(message)

    @channel.bind "Saldos" , (message) =>
      #console.log "Updating Saldos"
      #console.log message
      results = Saldo.updateFromSocket(message)
      Saldo.onQuerySuccess()

    @channel.bind "Productos" , (message) =>
      #console.log "Updating Productos"
      #console.log message
      results = Producto.updateFromSocket(message)

    @channel.bind "PedidoPreparado" , (message) =>
      #console.log "Updating PedidoPreparado"
      #console.log message
      results = PedidoPreparado.updateFromSocket(message)
      if Spine.session.hasPerfiles(['Platform System Admin','Ejecutivo Credito'])
        Spine.notifications.showNotification( "Pedidos Preparados" , "Han ingresado nuevos pedidos" )

    @channel.bind "PedidoAprobado" , (message) =>
      #console.log "Updating PedidoAprobado"
      #console.log message
      results = PedidoPreparado.updateFromSocket(message)

    @channel.bind "FacturaPreparada" , (message) =>
      #console.log "Updating FacturaPreparada"
      
      results = FacturaPreparada.updateFromSocket(message)
      if results  != false
        if Spine.session.hasPerfiles(['Platform System Admin','Ejecutivo Ventas' , 'Encargado de Ventas'])
          Spine.notifications.showNotification( "Aprobacion de Facturas" , "Facturas Listas para Imprimir" )

    @channel.bind "FacturaImpresa" , (message) =>
      #console.log "Updating FacturaImpresa"
      results = FacturaPreparada.updateFromSocket(message)

module.exports = SocketManager