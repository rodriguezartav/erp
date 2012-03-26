Spine   = require('spine')
User = require('models/user')
Recibo = require('models/recibo')
$       = Spine.$

class SendRecibo extends Spine.Controller
  className: 'sendRecibo modal'

  elements:
    ".alert-box" : "alert_box"
    ".loader" : "loader"

  events:
    "click .accept" : "on_error_accept"
  
  @type = "sendRecibo"

  constructor: ->
    super
    @recibo = @data
    @html require('views/lightbox/sendRecibo')
    Recibo.insert([@recibo])
    Recibo.bind "insert_error" , @on_error
    Recibo.bind "insert_success" , @on_success

  on_success: (results) =>
    Recibo.unbind "insert_error" , @on_error
    Recibo.unbind "insert_success" , @on_success   
    @loader.hide()
    @callback.apply @, [true]
    Spine.trigger "hide_lightbox"

  on_error: (error_obj) =>
    Recibo.unbind "insert_error" , @on_error
    Recibo.unbind "insert_success" , @on_success
    @loader.hide()
    @el.addClass "error"
    @alert_box.show()
    @alert_box.append "<p>#{error.errors}</p>" for error in error_obj
  
  on_error_accept: =>
    @el.removeClass "error"
    Spine.trigger "hide_lightbox"
    
module.exports = SendRecibo