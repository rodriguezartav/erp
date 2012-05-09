Spine   = require('spine')
$       = Spine.$

class Update extends Spine.Controller
  className: 'update modal'

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

  @type = "update"

  constructor: ->
    super
    @html require('views/lightbox/update')(@data)
    
    @data.class.bind "insert_error" , @on_error
    @data.class.bind "insert_success" , @on_success
    @show_input.hide()
    @show_wait.show()
    @data.class.rest( @data.restRoute , @data.restMethod , @data.restData ) 


  on_success: (results) =>
    @data.class.unbind "insert_error" , @on_error
    @data.class.unbind "insert_success" , @on_success  
    @html require('views/lightbox/success')
    @callback.apply @, [true]
    Spine.trigger "hide_lightbox"

  on_error: (error_obj) =>
    @data.class.unbind "insert_error" , @on_error
    @data.class.unbind "insert_success" , @on_success
    @loader.hide()
    @el.addClass "error"
    @alert_box.show()
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
    
module.exports = Update