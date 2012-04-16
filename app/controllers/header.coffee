Spine = require('spine')
  
class Header  extends Spine.Controller
  className: "header"
  
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
    @loader.hide()
    
    Spine.bind "query_start",=>
      @loader.show()

    Spine.bind "query_complete",=>
      @loader.hide()
      
    Spine.bind "status_changed" , =>
      if Spine.status == "offline"
        @status_button.addClass "btn-danger" 
        @status_button.removeClass "btn-success"
        @status_button_label.html "Off Line"
        
      else if Spine.status == "online"
        @status_button.addClass "btn-success" 
        @status_button.removeClass "btn-danger"
        @status_button_label.html "On Line"


  reset: ->
    for model in Spine.nSync
      model.destroyAll()
    Spine.session.resetLastUpdate()
    window.location.reload()

  
module.exports = Header
