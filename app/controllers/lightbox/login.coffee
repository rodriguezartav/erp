Spine   = require('spine')
Session = require('models/session')
$       = Spine.$
StatManager = require("managers/statManager")

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
    if @data.salesforceSession
      Spine.session.loadFromSalesforce(@data.salesforceSession) 
      Spine.session.salesforceLogin({user_id: @data.salesforceSession.user_id })
      @login_effect()
    else
      if Spine.session.token and !Spine.session.isExpired()
        if navigator.onLine
          @renderComplete()
        else
          @renderOffLine()
      else
        @renderLogin()

    Session.bind "login_success" , =>
      @onLoginSuccess()
      
    Session.bind "login_error" , (response) =>
      @renderLogin(response.error)

    Session.bind "no_net" , ->
      @renderNoNet()

  login: =>
    Spine.session.username = @txt_email.val()
    Spine.session.passwordToken = @txt_token.val()
    Spine.session.password = @txt_password.val()
    Spine.session.save()  
    Spine.session.login()
    @login_effect()

  login_effect: =>
    @loader.show()
    @alert_box.hide()
    @login.hide()

  onLoginSuccess: =>
    ##STAT
    StatManager.identify Spine.session.user
    StatManager.sendEvent 'Login' , {Profile: Spine.session.user.Profile__c }
    @renderComplete()

  on_continue: =>
    ##STAT
    Spine.notifications.checkPermision()
    
    StatManager.identify Spine.session.user
    StatManager.sendEvent 'Session Reload'

    Spine.trigger "hide_lightbox"
    Spine.trigger "login_complete"
    @callback?.apply @, [true]


  renderLogin: (error = false ) =>
    @html require("views/controllers/lightbox/login/login")(Spine.session)
    if error
      @alert_box.show()
      @alert_box.html error
  
  renderOffLine: =>
    @html require("views/controllers/lightbox/login/noNet")(Spine.session)

  renderComplete: =>
    @html require("views/controllers/lightbox/login/complete")(Spine.session)

  cancel: =>
    @renderOffLine()

module.exports = Login