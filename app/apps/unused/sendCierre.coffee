Spine   = require('spine')
User = require('models/user')
Cierre = require('models/cierre')
$       = Spine.$

class sendCierre extends Spine.Controller
  className: 'sendCierre modal'

  elements:
    ".alert-box" : "alert_box"
    ".loader" : "loader"

  events:
    "click .accept" : "on_error_accept"

  @type = "sendCierre"


  constructor: ->
    super
    @cierre = @data
    @html require('views/lightbox/sendCierre')  
    Cierre.sendToServer( User.current ,  @cierre)
    Cierre.bind "send_error" , @on_error
    Cierre.bind "send_complete" , @on_success

  on_success: (results) =>
    Cierre.unbind "send_error" , @on_error
    Cierre.unbind "send_complete" , @on_success    
    @loader.hide()
    @callback.apply @, [true]
    Spine.trigger "hide_lightbox"

  on_error: (error_obj) =>
    Cierre.unbind "send_error" , @on_error
    Cierre.unbind "send_complete" , @on_success
    @loader.hide()
    @el.addClass "error"
    @alert_box.show()
    @alert_box.html error_obj.error
  
  on_error_accept: =>
    @el.removeClass "error"
    Spine.trigger "hide_lightbox"
    
module.exports = sendCierre