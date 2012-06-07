Spine = require('spine')
Productos = require("controllers/productos")
Saldo = require("models/socketModels/saldo")
Cliente = require("models/cliente")
Producto = require("models/producto")

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
    "click .update" : "onUpdate"
  
  constructor: ->
    super
    @html require('views/controllers/header/layout')
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

  onUpdate: ->
    Saldo.bind "bulk_deleted" , @onDeleteDone
    Spine.trigger "show_lightbox" , "showWait" , error: "Esto puede tomar varios minutos, cuando se complete el proceso se refrescara la pagina."
    Saldo.bulkDelete()
    Cliente.query({credito: true} , false)
    Cliente.query({contado: true} , false)
    Producto.query({},false)


  onDeleteDone: =>
    Saldo.query( { saldo: true } , false)
    console.log @onUpdateDone
    Saldo.bind "query_success" , @onUpdateDone
    
  onUpdateDone: ->
    window.location.reload()

  reset: ->
    for model in Spine.socketModels
      model.forceDelete()

    for model in Spine.transitoryModels
      model.destroyAll()

    Spine.session.resetLastUpdate()

    window.location.reload()

  
module.exports = Header
