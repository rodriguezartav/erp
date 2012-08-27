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
    ".pause"      : "pauseBtn"
    ".update"     : "updateBtn"
  
  events:
    "click .reset"         : "reset"
    "click .update"        : "onUpdate"
    "click .pause"         : "onPause"
  
  constructor: ->
    super
    @html require('views/controllers/footer/layout')
    Spine.bind "actualizar_ahora" , @onUpdate
    Spine.bind "master_reset" , @reset
    
    Spine.bind "queryBegin" , =>
      @updateBtn.addClass "loading"      
    
    Spine.bind "queryComplete" , =>
      return false if Spine.queries > 0
      @updateBtn.removeClass "loading"
    
    
    @pauseTimer = null
    @pauseTimerRun = 0

  onPause: (e) =>
    Spine.paused = true
    @pauseBtn.addClass "active"
    clearTimeout(@pauseTimer) if @pauseTimer
    @pauseTimer = setTimeout =>
      @pauseBtn.removeClass "active"
      Spine.paused = false
    , 120000


  onUpdate: =>
    Saldo.bind "bulk_deleted" , @onDeleteDone
    Spine.trigger "show_lightbox" , "showWait" , error: "Esto puede tomar varios minutos, cuando se complete el proceso se refrescara la pagina."
    Saldo.bulkDelete()
    Cliente.ajax().query({credito: true} , false)
    Cliente.ajax().query({contado: true} , false)
    Producto.ajax().query({},false)

  onDeleteDone: =>
    Saldo.ajax().query( { saldo: true } , afterSuccess:  @onUpdateDone )


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
