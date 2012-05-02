Spine = require('spine')
Productos = require("controllers/productos")

  
class Header  extends Spine.Controller
  
  elements:
    ".loader"  : "loader"
    ".online"  : "online"
    ".offline" : "offline"
    ".status_button" : "status_button"
    ".status_button_label" : "status_button_label"

  events:
    "click .reset" : "reset"
  
  constructor: ->
    super
    @html require('views/header/layout')
    $('.dropdown-toggle').dropdown()
    @loader.hide()
    
    new Productos( el: @el )
    
    Spine.bind "query_start",=>
      @loader.show()

    Spine.bind "query_complete",=>
      @loader.hide()
      
    Spine.bind "status_changed" , =>
      if navigator.onLine
        @status_button.addClass "btn-success" 
        @status_button.removeClass "btn-danger"
        @status_button.removeClass "btn-warning"
        @status_button_label.html "ONLINE"
      else 
        @status_button.addClass "btn-danger" 
        @status_button.removeClass "btn-success"
        @status_button.removeClass "btn-warning"
        @status_button_label.html "OFFLINE"
        
    


  reset: ->
    for model in Spine.nSync
      model.destroyAll()
    Spine.session.resetLastUpdate()
    window.location.reload()

  
module.exports = Header
