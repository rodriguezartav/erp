Spine = require('spine')
Cliente = require("models/cliente")
Producto = require("models/producto")
User = require("models/user")


class Header  extends Spine.Controller
  
  
  elements:
    ".users" : "users"
    ".currentUser" : "currentUser"

  events:
    "click .home"          : "onHome"
  
  constructor: ->
    super
    @html require('views/controllers/header/layout')
    $('.dropdown-toggle').dropdown()
    User.bind "refresh" , @onUserFresh

  onUserFresh: =>
    @users.html require("views/controllers/header/user")(User.all())
    user = User.exists Spine.session.userId
    @currentUser.html require("views/controllers/header/user")([user])

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
