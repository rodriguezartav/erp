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
    "click .toSalesforce" : "onClickSalesforce"
  
  constructor: ->
    super
    @html require('views/header/layout')
    $('.dropdown-toggle').dropdown()
    
    new Productos( el: @el )
    
    Spine.bind "query_start",=>
      @loader.addClass "animate"

    Spine.bind "query_complete",=>
      @loader.removeClass "animate" if Spine.salesforceQueryQueue == 0
      
    Spine.bind "status_changed" , =>
      if navigator.onLine
        @status_button.addClass "btn-success" 
        @status_button.removeClass "btn-danger"
        @status_button.removeClass "btn-warning"
        @status_button_label.html '<i class="icon-ok"></i>'
      else 
        @status_button.addClass "btn-danger" 
        @status_button.removeClass "btn-success"
        @status_button.removeClass "btn-warning"
        @status_button_label.html '<i class="icon-remove"></i>'

  onClickSalesforce: =>
    window.open Spine.session.instance_url + "/home/home.jsp"

  reset: ->
    for model in Spine.socketModels
      model.destroyAll()

    for model in Spine.transitoryModels
      model.destroyAll()

    Spine.session.resetLastUpdate()
    window.location.reload()

  
module.exports = Header
