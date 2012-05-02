Spine = require('spine')

class Session extends Spine.SingleModel
  @configure "Session" , "instance_url", "token" , "userId",
    "username" , "password" ,"passwordToken" ,
    "user"
    "lastLogin","lastUpdate"
    "error" , "isOnline","isSalesforce"
  
  @extend Spine.Model.Salesforce
  
  constructor: ->
    super
    @isSalesforce=false

  resetLastUpdate: ->
    @lastUpdate = {}
    @save()

  setLastUpdate: (className) ->
    @lastUpdate = {} if !@lastUpdate
    @lastUpdate[className] = new Date()
    @save()
  
  getLastUpdate: (className) =>
    lastUpdate = new Date('1/1/1970').getTime()
    lastUpdate = @lastUpdate?[className] if @lastUpdate[className]
    lastUpdate = new Date(lastUpdate)
    return lastUpdate


    console.log "Session: " + lastUpdate


  sessionExpires: =>
    expire = new Date(@lastLogin.getTime() + 1000 * 60 * 60)
    return expire
  
  #used for debbugin
  expireSession: =>
    @lastLogin = new Date('1-1-1970')
    @save()

  loadFromSalesforce: (params) =>
    @instance_url = params.instance_url
    @token        = params.token
    @isSalesforce = true
    @save()

  isExpired: () =>
    return true if !@lastLogin
    expireDate = new Date(@lastLogin.getTime() + 1000 * 60 * 60 * 2)
    res = false
    res= true if expireDate.getTime()  < new Date().getTime() 
    return res

  login:  =>
    $.ajax
      url: Spine.server + "/login"
      type: "POST"
      data: {username: @username, password: @password + @passwordToken}
      success: @on_login_success
      error: @on_login_error

  salesforceLogin: (options)  =>
    $.ajax
      url: Spine.server + "/login"
      type: "POST"
      data: Session.ajaxParameters(options)
      success: @on_login_success
      error: @on_login_error

  on_login_success: (raw_results) =>
     results = JSON.parse raw_results 
     @instance_url = results.instance_url
     @token = results.token
     @userId = results.userId
     @user = results.user[0]
     @lastLogin = new Date()
     @save()
     Session.trigger "login_success" , @

  on_login_error: (error) =>
    responseText  = error.responseText
    if responseText.length > 0
      @errors = JSON.parse responseText
      @save()
      Session.trigger "login_error" , @
    else
      @noNetError()

  noNetError: ->
    @errors = {type:"LOCAL" , error: "No hay conexion a internet", source: "Session" }
    Spine.trigger "no_net_error" , @ 
    
    
module.exports = Session

