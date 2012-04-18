Spine   = require('spine')
User = require('models/user')
Documento = require('models/documento')
$       = Spine.$

class AnularDocumento extends Spine.Controller
  className: 'anukarDocumento modal'

  elements:
    ".alert-box" : "alert_box"
    ".loader" : "loader"

  events:
    "click .accept" : "on_error_accept"
  
  @type = "anularDocumento"

  constructor: ->
    super
    @documento = @data
    @html require('views/lightbox/anularDocumento')
    Documento.anular(@documento)
    Documento.bind "insert_error" , @on_error
    Documento.bind "insert_success" , @on_success

  on_success: (results) =>
    Documento.unbind "insert_error" , @on_error
    Documento.unbind "insert_success" , @on_success   
    @loader.hide()
    @callback.apply @, [true]
    Spine.trigger "hide_lightbox"

  on_error: (error_obj) =>
    Documento.unbind "insert_error" , @on_error
    Documento.unbind "insert_success" , @on_success
    @loader.hide()
    @el.addClass "error"
    @alert_box.show()
    @alert_box.append "<p>#{error.errors}</p>" for error in error_obj
  
  on_error_accept: =>
    @el.removeClass "error"
    Spine.trigger "hide_lightbox"
    
module.exports = AnularDocumento