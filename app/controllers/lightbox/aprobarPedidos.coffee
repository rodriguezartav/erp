Spine   = require('spine')
User = require('models/user')
Cliente = require("models/cliente")
PedidoPreparado = require("models/socketModels/pedidoPreparado")
Saldo = require("models/socketModels/saldo")
$       = Spine.$

class AprobarPedidos extends Spine.Controller
  className: 'aprobarPedidos modal'

  elements:
    ".alert-box"   : "alert_box"
    ".loader"      : "loader"
    ".show_wait"   : "show_wait" 
    ".show_input"  : "show_input"
    "textarea"     : "observacion"
    ".list_info"   : "list_info"

  events:
    "click .accept" : "on_error_accept"
    "click .send" : "on_send_pedido"
    "click .cancel" : "on_cancel_pedido"

  @type = "aprobarPedidos"

  constructor: ->
    super
    cliente = Cliente.find(@data.group.Cliente)
    render = ''
   #if cliente.willOverDraft(@data.group.Total) and !@data.allowOverDraft
      #render = 'views/controllers/lightbox/aprobarPedidosNoClearance'
    if Saldo.overDraft(cliente) and !@data.allowOver60
      render = 'views/controllers/lightbox/aprobarPedidosSaldo60'
    else
      render = 'views/controllers/lightbox/aprobarPedidos'  
    @html require(render)(@data)
    @show_input.show()
    @show_wait.hide() 

  on_cancel_pedido: =>
    Spine.trigger "hide_lightbox"

  on_send_pedido: =>
    PedidoPreparado.bind "insert_error" , @on_error
    PedidoPreparado.bind "insert_success" , @on_success
    ids = []
    @show_input.hide()
    @show_wait.show() 

    for pedido in @data.group.Pedidos
      ids.push pedido.id

    data = JSON.stringify( { ids: ids , observacion: @observacion.val() , aprobar: @data.aprobar }  )
    PedidoPreparado.rest( 'Oportunidad' , 'PUT' , data ) 

  on_success: (results) =>
    PedidoPreparado.unbind "insert_error" , @on_error
    PedidoPreparado.unbind "insert_success" , @on_success  
    for pedido in @data.group.Pedidos
      pedido.destroy()
    Spine.trigger "hide_lightbox"
    @callback.apply @, [true]

  on_error: (error_obj) =>
    PedidoPreparado.unbind "insert_error" , @on_error
    PedidoPreparado.unbind "insert_success" , @on_success
    @loader.hide()
    @el.addClass "error"
    @alert_box.show()
    error = JSON.stringify(error_obj) || error_obj
    index = error.lastIndexOf "caused by: "
    if index > -1
      indexEnd = error.indexOf "Trigger"
      error = error.substring(index + 11 ,indexEnd)
    @alert_box.append "<p>#{error}</p>"
  
  on_error_accept: =>
    @alert_box.empty()
    @alert_box.hide()
    Spine.trigger "hide_lightbox"
    
module.exports = AprobarPedidos