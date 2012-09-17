Spine   = require('spine')
Session = require('models/session')
User = require('models/user')

$       = Spine.$
StatManager = require("managers/statManager")

class AuthLogin extends Spine.Controller
  @extend Spine.Controller.Modal
  
  className: 'login modal'

  events:
    "click .offline" : "onOffine"
    "click .requestPermision" : "requestPermision"

  @type = "authLogin"

  constructor: ->
    super
    
  loginProcess:->
    checkStatusRequest = $.get "/checkStatus"
    checkStatusRequest.success (data) =>
      Spine.session = Session.record || Session.create()
      Spine.session.createFromAuth(data)
      user = User.find Spine.session.userId
      Spine.session.user = user;
      Spine.session.save()
      return @render() if Spine.session.isExpired()
      @continue()
    
    checkStatusRequest.error =>
      @render()

  requestPermision: =>
    @loginProcess()
    window.webkitNotifications?.requestPermission?()
    
    

  continue: =>
    Spine.trigger "hide_lightbox"
    Spine.trigger "login_complete"
    @callback()

  render: ->
    @html require("views/controllers/lightbox/login/authLogin")

  onOffine: ->
    return @render() if !Session.record
    Spine.session = Session.record
    console.log Spine.session
    Spine.trigger "hide_lightbox"
    Spine.trigger "login_complete"
    @callback()
    

module.exports = AuthLogin