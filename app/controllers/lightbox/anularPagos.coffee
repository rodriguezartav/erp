Spine   = require('spine')
User = require('models/user')
Pago = require("models/pago")
$       = Spine.$

class AnularPagos extends Spine.Controller
  className: 'anularPago modal'

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

  @type = "anularPagos"

  constructor: ->
    super
    @html require('views/lightbox/anularPago')(@data)
    Pago.bind "insert_error" , @on_error
    Pago.bind "insert_success" , @on_success
    @show_input.hide()
    @show_wait.show()
    Pago.rest( "Pago" , "POST" , JSON.stringify({ reciboId: @data.reciboId }) )

  on_cancel_pedido: =>
    Spine.trigger "hide_lightbox"

  on_success: (results) =>
    Pago.unbind "insert_error" , @on_error
    Pago.unbind "insert_success" , @on_success  
    Spine.trigger "hide_lightbox"
    @callback.apply @, [true]

  on_error: (error_obj) =>
    Pago.unbind "insert_error" , @on_error
    Pago.unbind "insert_success" , @on_success
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
    
module.exports = AnularPagos