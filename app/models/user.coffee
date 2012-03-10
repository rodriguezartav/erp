Spine = require('spine')

class User extends Spine.Model
  @configure "User", "email" , "token" , "password" , "session" ,  "errors" , "is_visualforce"
  @extend Spine.Model.Local

  to_credentials: ->
    { username: @email, password: @password + @token  }
  
  to_auth: (params) ->
    params.instance_url= @session.instance_url
    params.token= @session.token
    params.host= @session.host
    params

  @retrieve: ->
    new_user = User.last() or {email: "" , password: "" , token: "" ,  errors: [] , session: null}
    @current = User.create new_user
    @current.save()

  @login: (email , token="" , password) =>
    @current.updateAttributes {email: email , token: token or "" , password: password , session: null }
    @current.save()
    $.ajax
      url: Spine.server + "/login"
      type: "POST"
      data: @current.to_credentials()
      success: @on_login_success
      error: @on_login_error

  @on_login_success: (raw_results) =>
     results = JSON.parse raw_results
     current = User.current
     current.session = results
     current.save()
     User.trigger "login_complete"
      
  @on_login_error: (error) =>
    responseText  = error.responseText
    if responseText.length > 0
      errors = JSON.parse responseText
      current = User.current
      current.errors.push errors
      current.password = null
      current.session = null
      current.save()
      User.trigger "login_error" , errors  
    else
      errors = {type:"LOCAL" , error: " Indefinido: Posiblemente Problema de Red", source: "Cliente" }
      User.trigger "login_no_net_error" , errors  


module.exports = User