Spine = require('spine')
class Session extends Spine.SingleModel
  @configure "Session" , "instance_url", "userId" , "lastLogin" , "lastUpdate" , "isOnline" , "isSalesforce" , "user"
  @extend Spine.Model.SalesforceModel
  @extend Spine.Model.SalesforceAjax.Methods

  constructor: ->
    super
    @isSalesforce=false

  createFromAuth: (keys) ->
    lastSlash = keys.id.lastIndexOf "/"
    @userId = keys.id.substring(lastSlash + 1)
    @instance_url= keys.instance_url
    @lastLogin= new Date( parseInt( keys.issued_at ))
    @save()

  hasPerfiles: (perfiles) ->
    has = false
    for perfil in perfiles
      has = true if perfil == @user.Perfil
    return has

  resetLastUpdate: ->
    @lastUpdate = {}
    @token = null;
    @lastLogin = null;
    @save()

  setLastUpdate: (className) ->
    @lastUpdate = {} if !@lastUpdate
    @lastUpdate[className] = new Date()
    @save()
  
  getLastUpdate: (className) =>
    lastUpdate = new Date('1/1/1970').getTime()
    lastUpdate = @lastUpdate[className] if @lastUpdate && @lastUpdate[className]
    lastUpdate = new Date(lastUpdate)
    return lastUpdate

  getLastUpdateOr1970: (className) =>
    date = @getLastUpdate(className)
    try
      date.getTime() - (60*1000)
    catch error
      date = new Date('1970/1/1')
    return date;

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

  isExpired: =>
    return false if @lastLogin.less_than(110.minutes).ago
    console.log @lastLogin
    console.log "session is expired"
    return true

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
