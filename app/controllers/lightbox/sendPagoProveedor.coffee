Spine   = require('spine')
User = require('models/user')
Pedido = require("models/pedido")
PagoProveedor = require("models/transitory/pagoProveedor")

$       = Spine.$

class SendPagoProveedor extends Spine.Controller
  className: 'sendPagoProveedor modal'
  @type = "sendPagoProveedor"

  elements:
    ".alert-box"   : "alert_box"
    ".loader"      : "loader"
    ".show_wait"   : "show_wait" 

  events:
    "click .accept" : "on_error_accept"
    "click .send" : "on_send_pedido"
    "click .cancel" : "on_cancel_pedido"


  constructor: ->
    super
    @html require('views/lightbox/sendPagoProveedor')
    Pedido.bind "insert_error" , @on_error
    Pedido.bind "insert_success" , @on_success
    PagoProveedor.insert(@data)

  on_success: (results) =>
    Pedido.unbind "insert_error" , @on_error
    Pedido.unbind "insert_success" , @on_success  
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
    
module.exports = SendPagoProveedor