Spine = require('spine')
User = require("models/user")
Saldo = require("models/socketModels/saldo")
Cliente = require("models/cliente")
Producto = require("models/producto")
  
class Footer  extends Spine.Controller
  className: "navbar navbar-fixed-left"
  
  elements:
    ".users" : "users"
    ".currentUser" : "currentUser"
  
  events:
    "click .reset"         : "reset"
    "click .update"        : "onUpdate"
  
  
  
  constructor: ->
    super
    @html require('views/controllers/footer/layout')
    Spine.bind "actualizar_ahora" , @onUpdate
    Spine.bind "master_reset" , @reset


  onUpdate: =>
    Saldo.bind "bulk_deleted" , @onDeleteDone
    Spine.trigger "show_lightbox" , "showWait" , error: "Esto puede tomar varios minutos, cuando se complete el proceso se refrescara la pagina."
    Saldo.bulkDelete()
    Cliente.query({credito: true} , false)
    Cliente.query({contado: true} , false)
    Producto.query({},false)

  onDeleteDone: =>
    Saldo.query( { saldo: true } , false)
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


module.exports = Footer
