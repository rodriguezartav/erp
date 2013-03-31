Spine = require('spine')
Cliente = require("models/cliente")
Producto = require("models/producto")
User = require("models/user")

Kpi = require("controllers/kpi")

class Header  extends Spine.Controller

  elements:
    ".users" : "users"
    ".currentUser" : "currentUser"
    ".update"     : "updateBtn"
    ".src_kpi" : "srcKpi"

  events:
    "click img"          : "onHome"
    "click .currentUser"   : "onCurrentUserClick"
    "click .update"        : "onUpdate"
    "click .showClienteCanvas" : "onShowClienteCanvas"
    "click input" : "onInputClick"

  
  constructor: ->
    super
    @html require('views/controllers/header/layout')

   # kpi = new Kpi(el: @srcKpi )
    
    $('.dropdown-toggle').dropdown()
    Spine.bind "login_complete" , @onLoginComplete
    
    Spine.bind "actualizar_ahora" , @onUpdate

    Spine.bind "queryBegin" , =>
      @updateBtn.addClass "loading"      

    Spine.bind "queryComplete" , =>
      return false if Spine.queries > 0
      @updateBtn.removeClass "loading"

  onInputClick: (e) =>
    target = $(e.target)
    target.select()

  onUpdate: =>
    Spine.reset()

  onLoginComplete: =>
    user = User.exists Spine.session.userId
    @currentUser.html require("views/controllers/header/user")([user])

    clientes = []
    for cliente in Cliente.all()
      clientes.push cliente.Name

    typeahead = @el.find(".searchClientes").typeahead source: clientes , updater: @onClienteItemClick

  onClienteItemClick: (name) =>
    cliente = Cliente.findByAttribute "Name" , name
    Spine.trigger "showClienteCanvas" , cliente
    return name

  onCurrentUserClick: =>
    @users.html require("views/controllers/header/user")(User.all()) if !@loaded
    @loaded = true

  onShowClienteCanvas: =>
    Spine.trigger "showClienteCanvas"

  onHome: ->
    @navigate "/apps"

  
module.exports = Header