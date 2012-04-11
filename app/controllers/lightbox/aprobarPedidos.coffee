Spine   = require('spine')
User = require('models/user')
Pedido = require("models/pedido")
$       = Spine.$

class AprobarPedidos extends Spine.Controller
  className: 'aprobarPedidos modal'

  elements:
    ".alert-box"   : "alert_box"
    ".loader"      : "loader"
    ".show_wait"   : "show_wait" 
    ".show_input"  : "show_input"
    "textarea"     : "observacion"

  events:
    "click .accept" : "on_error_accept"
    "click .send" : "on_send_pedido"
    "click .cancel" : "on_cancel_pedido"

  @type = "aprobarPedidos"

  constructor: ->
    super
    @html require('views/lightbox/aprobarPedidos')(@data)
    @show_input.show()
    @show_wait.hide() 

  on_cancel_pedido: =>
    Spine.trigger "hide_lightbox"

  on_send_pedido: =>
    Pedido.bind "insert_error" , @on_error
    Pedido.bind "insert_success" , @on_success
    ids = []
    @show_input.hide()
    @show_wait.show() 

    for pedido in @data.group.Pedidos
      ids.push pedido.id

    Pedido.aprobar( ids , @observacion.val() || " Sin razon de Aprobacion de Pedidos." , @data.aprobar)

  on_success: (results) =>
    Pedido.unbind "insert_error" , @on_error
    Pedido.unbind "insert_success" , @on_success  
    for pedido in @data.group.Pedidos
      pedido.destroy()
    Spine.trigger "hide_lightbox"
    @callback.apply @, [true]

  on_error: (error_obj) =>
    Pedido.unbind "insert_error" , @on_error
    Pedido.unbind "insert_success" , @on_success
    @loader.hide()
    @el.addClass "error"
    @alert_box.show()
    error = JSON.stringify(error_obj) || error_obj
    @alert_box.append "<p>#{error}</p>"
  
  on_error_accept: =>
    @alert_box.empty()
    @alert_box.hide()
    Spine.trigger "hide_lightbox"
    
module.exports = AprobarPedidos