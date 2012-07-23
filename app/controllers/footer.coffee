Spine = require('spine')
Productos = require("controllers/productos")

  
class Footer  extends Spine.Controller
  className: "navbar navbar-fixed-left"
  
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
    @html require('views/controllers/footer/layout')
    
    
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

  
module.exports = Footer
