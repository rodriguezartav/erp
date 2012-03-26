Spine   = require('spine')
Session = require('models/session')
$       = Spine.$

class Login extends Spine.Controller
  className: 'login modal'

  elements:
    "#txt_email" : "txt_email"
    "#txt_password" : "txt_password"
    "#txt_token" : "txt_token"
    ".alert-box" : "alert_box"
    ".loader" : "loader"
    ".login"   : "login"
    ".continue"   : "continue"

  events:
    "click .login" : "login"
    "click .continue" : "on_continue"
    "click .close-reveal-modal" : "cancel"

  @type = "login"

  constructor: ->
    super
    Spine.session = Session.record || Session.create()
    @data = {} if !@data
    Spine.session.loadFromSalesforce(@data.salesforceSession) if @data.salesforceSession
    if Spine.session.token and !Spine.session.isExpired()
      if navigator.onLine
        @renderComplete()
      else
        @renderOffline()
    else
      @renderLogin()

    Session.bind "login_success" , =>
      @renderComplete()
      
    Session.bind "login_error" , (response) =>
      @renderLogin(response.error)

    Session.bind "no_net" , ->
      @renderNoNet()


  askForNotificationPermision: ->
    if window.webkitNotifications.checkPermission() != 0
      window.webkitNotifications.requestPermission();

  login: =>
    @askForNotificationPermision()
    Spine.session.username = @txt_email.val()
    Spine.session.passwordToken = @txt_token.val()
    Spine.session.password = @txt_password.val()
    Spine.session.save()
    
    Spine.session.login()
    @loader.show()
    @alert_box.hide()
    @login.hide()

  on_continue: =>
    @askForNotificationPermision()
    Spine.trigger "hide_lightbox"
    @callback?.apply @, [true]    

  renderLogin: (error = false ) =>
    @html require("views/lightbox/login/login")(Spine.session)
    if error
      @alert_box.show()
      @alert_box.html error
  
  renderOffLine: ->
    @html require("views/lightbox/login/noNet")(Spine.session)

  renderComplete: =>
    @html require("views/lightbox/login/complete")(Spine.session)


module.exports = Login