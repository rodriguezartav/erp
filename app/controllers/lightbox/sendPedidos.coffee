Spine   = require('spine')
User = require('models/user')
PedidoItem = require('models/transitory/pedidoItem')
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
    PedidoItem.insert(@data)
    PedidoItem.bind "insert_error" , @on_error
    PedidoItem.bind "insert_success" , @on_success

  on_success: (results) =>
    PedidoItem.unbind "insert_error" , @on_error
    PedidoItem.unbind "insert_success" , @on_success    
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
    PedidoItem.unbind "insert_error" , @on_error
    PedidoItem.unbind "insert_success" , @on_success
    @loader.hide()
    @el.addClass "error"
    @alert_box.show()
    error = JSON.stringify(error_obj) || error_obj
    @alert_box.append "<p>#{error}</p>"
  
  on_error_accept: =>
    @alert_box.empty()
    @alert_box.hide()
    Spine.trigger "hide_lightbox"
    
module.exports = SendPedidos