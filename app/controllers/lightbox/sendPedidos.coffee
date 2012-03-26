Spine   = require('spine')
User = require('models/user')
Pedido = require('models/movimiento')
$       = Spine.$

class SendPedidos extends Spine.Controller
  className: 'sendPedidos modal'

  elements:
    ".alert-box" : "alert_box"
    ".loader" : "loader"

  events:
    "click .accept" : "on_error_accept"

  @type = "sendPedidos"

  constructor: ->
    super
    @html require('views/lightbox/sendPedidos')
    Pedido.send_to_server(User.current)
    Pedido.bind "ajax_error" , @on_error
    Pedido.bind "ajax_complete" , @on_success

  on_success: (results) =>
    Pedido.unbind "ajax_error" , @on_error
    Pedido.unbind "ajax_complete" , @on_success    
    @loader.hide()
    errors = []
    hasErrors = false
    for result in results
      if result.success
        source = result.source
      else
        hasErrors = true
        errors.push result
    
    if hasErrors
      @on_error errors
    else
      Spine.trigger "hide_lightbox"
      @callback.apply @, [true]

  on_error: (error_obj) =>
    Pedido.unbind "ajax_error" , @on_error
    Pedido.unbind "ajax_success" , @on_success
    @loader.hide()
    @el.addClass "error"
    @alert_box.show()
    @alert_box.append "<p>#{error.errors}</p>" for error in error_obj
  
  on_error_accept: =>
    @alert_box.empty()
    @alert_box.hide()
    Spine.trigger "hide_lightbox"
    
module.exports = SendPedidos