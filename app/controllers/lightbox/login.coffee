Spine   = require('spine')
User = require('models/user')
Cliente = require('models/cliente')
$       = Spine.$

class Login extends Spine.Controller
  className: 'login modal'

  elements:
    "#txt_email" : "txt_email"
    "#txt_password" : "txt_password"
    "#txt_token" : "txt_token"
    ".alert-box" : "alert_box"
    ".login" : "login"
    ".loader" : "loader"
    ".noNet"  : "noNet"

  events:
    "click .login" : "login"
    "click .cancel" : "cancel"
    "click .close-reveal-modal" : "cancel"


  constructor: ->
    super

  render: =>
    obj = localStorage.getItem("auth")
    try
      auth = JSON.parse obj
  
    @html require('views/lighthouse/login')(auth)
    
  login: =>
    obj = JSON.stringify { email: @txt_email.val() , token: @txt_token.val() }
    localStorage.setItem "auth" , obj
    @log localStorage.getItem("auth")
    User.bind "login_complete" , @on_login_complete
    User.bind "login_error" , @on_login_error
    User.bind "login_no_net_error" , @on_login_no_net_error  
    User.login  @txt_email.val(),  @txt_token.val() , @txt_password.val()

  on_login_complete: =>
    User.unbind "login_complete" , @on_login_complete
    User.unbind "login_error" , @on_login_error
    User.unbind "login_no_net_error" , @on_login_no_net_error
    Spine.trigger "hide_lightbox"

  on_login_error: (response) =>
    @alert_box.show()
    User.unbind "login_complete" , @on_login_complete
    User.unbind "login_error" , @on_login_error
    User.unbind "login_no_net_error" , @on_login_no_net_error
    @alert_box.html response.error
   
  cancel:->
    User.current.session = null
    
module.exports = Login