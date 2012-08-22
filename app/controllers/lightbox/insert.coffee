Spine   = require('spine')
User = require('models/user')
CuentaPorPagar = require('models/cuentaPorPagar')
$       = Spine.$

class Insert extends Spine.Controller
  className: 'insert modal'

  elements:
    ".alert-box" : "alert_box"
    ".loader" : "loader"

  events:
    "click .accept" : "on_error_accept"
  
  @type = "insert"

  constructor: ->
    super
    @html require('views/controllers/lightbox/insert')
    @data.ajax().create {} , afterSuccess: @on_success , afterError: @on_error

  on_success: (results) =>
    @html require('views/controllers/lightbox/success')
    @callback.apply @, [true]
    Spine.trigger "hide_lightbox", 1300

  on_error: (error_obj) =>
    @loader.hide()
    @el.addClass "error"
    @alert_box.show()
    @alert_box.append "<p>#{error.errors}</p>" for error in error_obj
  
  on_error_accept: =>
    @el.removeClass "error"
    Spine.trigger "hide_lightbox"
    
module.exports = Insert