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

  
  constructor: ->
    super
    @html require('views/controllers/header/layout')
    kpi = new Kpi(el: @srcKpi )
    
    $('.dropdown-toggle').dropdown()
    Spine.bind "login_complete" , @onUserFresh
    
    Spine.bind "actualizar_ahora" , @onUpdate

    Spine.bind "queryBegin" , =>
      @updateBtn.addClass "loading"      

    Spine.bind "queryComplete" , =>
      return false if Spine.queries > 0
      @updateBtn.removeClass "loading"


  onUpdate: =>
    Spine.reset()
    

  onUserFresh: =>
    user = User.exists Spine.session.userId
    @currentUser.html require("views/controllers/header/user")([user])

  onCurrentUserClick: =>
    @users.html require("views/controllers/header/user")(User.all()) if !@loaded
    @loaded = true

  onHome: ->
    @navigate "/apps"

  obsolte: ->
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

  
module.exports = Header
