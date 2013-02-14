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
    "click .update"        : "onUpdate"
  
  constructor: ->
    super
    @html require('views/controllers/footer/layout')
    Spine.bind "actualizar_ahora" , @onUpdate
    
    Spine.bind "queryBegin" , =>
      @updateBtn.addClass "loading"      
    
    Spine.bind "queryComplete" , =>
      return false if Spine.queries > 0
      @updateBtn.removeClass "loading"


  onUpdate: =>
    Spine.reset()

module.exports = Footer
