Spine   = require('spine')
User = require('models/user')
Recibo = require("models/recibo")
$       = Spine.$

class AprobarRecibos extends Spine.Controller
  className: 'aprobarRecibos modal'

  elements:
    ".alert-box"   : "alert_box"
    ".loader"      : "loader"
    ".show_wait"   : "show_wait" 
    "textarea"     : "observacion"

  events:
    "click .accept" : "on_error_accept"
   
  @type = "aprobarRecibos"

  constructor: ->
    super
    @html require('views/lightbox/aprobarRecibos')(@data)
    Recibo.bind "insert_error" , @on_error
    Recibo.bind "insert_success" , @on_success
    @show_wait.show() 

    Recibo.actualizar( @data.ids , @data.estado)

  on_success: (results) =>
    Recibo.unbind "insert_error" , @on_error
    Recibo.unbind "insert_success" , @on_success  
    Spine.trigger "hide_lightbox"
    @callback.apply @, [true]

  on_error: (error_obj) =>
    Recibo.unbind "insert_error" , @on_error
    Recibo.unbind "insert_success" , @on_success
    @loader.hide()
    @el.addClass "error"
    @alert_box.show()
    error = JSON.stringify(error_obj) || error_obj
    @alert_box.append "<p>#{error}</p>"
  
  on_error_accept: =>
    @alert_box.empty()
    @alert_box.hide()
    Spine.trigger "hide_lightbox"
    
module.exports = AprobarRecibos