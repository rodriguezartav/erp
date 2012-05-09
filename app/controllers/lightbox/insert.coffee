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
    @html require('views/lightbox/insert')
    
    @data.class.insert(@data.restData)
    @data.class.bind "insert_error" , @on_error
    @data.class.bind "insert_success" , @on_success

  on_success: (results) =>
    @data.class.unbind "insert_error" , @on_error
    @data.class.unbind "insert_success" , @on_success   
    @loader.hide()
    @callback.apply @, [true]
    @html require('views/lightbox/success')
    Spine.trigger "hide_lightbox", true

  on_error: (error_obj) =>
    @data.class.unbind "insert_error" , @on_error
    @data.class.unbind "insert_success" , @on_success
    @loader.hide()
    @el.addClass "error"
    @alert_box.show()
    @alert_box.append "<p>#{error.errors}</p>" for error in error_obj
  
  on_error_accept: =>
    @el.removeClass "error"
    Spine.trigger "hide_lightbox"
    
module.exports = Insert