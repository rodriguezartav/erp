Spine   = require('spine')
User = require('models/user')
PagoItem = require('models/transitory/pagoItem')
$       = Spine.$

class SendPagos extends Spine.Controller
  className: 'sendPagos modal'

  elements:
    ".alert-box" : "alert_box"
    ".loader" : "loader"

  events:
    "click .accept" : "on_error_accept"

  @type = "sendPagos"

  constructor: ->
    super
    @html require('views/lightbox/sendPagos')
    PagoItem.insert(@data)
    PagoItem.bind "insert_error" , @on_error
    PagoItem.bind "insert_success" , @on_success

  on_success: (results) =>
    PagoItem.unbind "insert_error" , @on_error
    PagoItem.unbind "insert_success" , @on_success   
    @loader.hide()
    @callback.apply @, [true]
    Spine.trigger "hide_lightbox"

  on_error: (error_obj) =>
    PagoItem.unbind "insert_error" , @on_error
    PagoItem.unbind "insert_success" , @on_success
    @loader.hide()
    @el.addClass "error"
    @alert_box.show()
    @alert_box.append "<p>#{error.errors}</p>" for error in error_obj
  
  on_error_accept: =>
    @alert_box.empty()
    @alert_box.hide()
    Spine.trigger "hide_lightbox"
    
module.exports = SendPagos