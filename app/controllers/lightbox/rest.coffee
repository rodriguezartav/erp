Spine   = require('spine')
$       = Spine.$

class Rest extends Spine.Controller
  className: 'rest modal'

  elements:
    ".alert-box"   : "alert_box"
    ".loader"      : "loader"
    ".show_wait"   : "show_wait" 
    ".show_input"  : "show_input"
    "textarea"     : "observacion"
    ".list_info"   : "list_info"

  events:
    "click .accept" : "on_error_accept"
    "click .send" : "on_send_pedido"

  @type = "rest"

  constructor: ->
    super
    @html require('views/controllers/lightbox/rest')(@data)
    @show_input.hide()
    @show_wait.show()
    @data.class.rest( @data , afterSuccess: @on_success, afterError: @on_error ) 


  on_success: (results) =>
    @html require('views/controllers/lightbox/success')      
    @callback.apply @, [true,results]
    Spine.trigger "hide_lightbox" , 1300

  on_error: (error_obj) =>
    @loader.hide()
    @el.addClass "error"
    @alert_box.show()
    console.log error_obj
    error = JSON.stringify(error_obj) || error_obj
    index = error.lastIndexOf "caused by: "
    if index > -1
      indexEnd = error.indexOf "Trigger"
      error = error.substring(index + 11 ,indexEnd)
    @alert_box.append "<p>#{error}</p>"
  
  on_error_accept: =>
    @alert_box.empty()
    @alert_box.hide()
    Spine.trigger "hide_lightbox"
    
module.exports = Rest