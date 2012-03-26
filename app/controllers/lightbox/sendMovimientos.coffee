Spine   = require('spine')
User = require('models/user')
Movimiento = require('models/movimiento')
$       = Spine.$

class SendMovimientos extends Spine.Controller
  className: 'sendMovimientos modal'

  elements:
    ".alert-box" : "alert_box"
    ".loader" : "loader"

  events:
    "click .accept" : "on_error_accept"

  @type = "sendMovimientos"

  constructor: ->
    super
    @html require('views/lightbox/sendMovimientos')
    Movimiento.insert(Movimiento.all())
    Movimiento.bind "insert_error" , @on_error
    Movimiento.bind "insert_success" , @on_success

  on_success: (results) =>
    Movimiento.unbind "insert_error" , @on_error
    Movimiento.unbind "insert_success" , @on_success    
    @loader.hide()
    errors = []
    hasErrors = false
    Spine.trigger "hide_lightbox"
    @callback.apply @, [true]

  on_error: (error_obj) =>
    Movimiento.unbind "insert_error" , @on_error
    Movimiento.unbind "insert_success" , @on_success
    @loader.hide()
    @el.addClass "error"
    @alert_box.show()
    @alert_box.append "<p>#{error.errors}</p>" for error in error_obj
  
  on_error_accept: =>
    @alert_box.empty()
    @alert_box.hide()
    Spine.trigger "hide_lightbox"
    
module.exports = SendMovimientos