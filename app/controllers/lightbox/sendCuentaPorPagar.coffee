Spine   = require('spine')
User = require('models/user')
CuentaPorPagar = require('models/cuentaPorPagar')
$       = Spine.$

class SendCuentaPorPagar extends Spine.Controller
  className: 'sendDocumento modal'

  elements:
    ".alert-box" : "alert_box"
    ".loader" : "loader"

  events:
    "click .accept" : "on_error_accept"
  
  @type = "sendCuentaPorPagar"

  constructor: ->
    super
    @cuentaPorPagar = @data
    @html require('views/lightbox/sendCuentaPorPagar')
    CuentaPorPagar.insert([@cuentaPorPagar])
    CuentaPorPagar.bind "insert_error" , @on_error
    CuentaPorPagar.bind "insert_success" , @on_success

  on_success: (results) =>
    CuentaPorPagar.unbind "insert_error" , @on_error
    CuentaPorPagar.unbind "insert_success" , @on_success   
    @loader.hide()
    @callback.apply @, [true]
    Spine.trigger "hide_lightbox"

  on_error: (error_obj) =>
    CuentaPorPagar.unbind "insert_error" , @on_error
    CuentaPorPagar.unbind "insert_success" , @on_success
    @loader.hide()
    @el.addClass "error"
    @alert_box.show()
    @alert_box.append "<p>#{error.errors}</p>" for error in error_obj
  
  on_error_accept: =>
    @el.removeClass "error"
    Spine.trigger "hide_lightbox"
    
module.exports = SendCuentaPorPagar