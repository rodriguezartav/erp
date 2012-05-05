Spine = require('spine')
Session = require('models/session')
Lightbox = require("controllers/lightbox")


class ConnectionManager

  constructor: ->

    @connectionStatus= "online"
    @startupSequence()
    Spine.bind "login_complete" , @loginSequence
    window.setInterval( @checkOverallStatus , 10000 )
    @cyclesCount = 0

  startupSequence: ->
    @fetchLocalData()

  updateSequence: ->
    @fetchServerData()

  loginSequence: =>
    @updateSequence()

  goOnlineSequence: ->
    Spine.trigger "status_changed" , @connectionStatus
    
    if Spine.session.isExpired()
      @refreshSession()
    else
      Spine.trigger "show_lightbox" , "showWarning" , error: "Informacion: Regreso el Internet, Continue Normalmente"
      @updateSequence()
      @resetSocketSequence()
 
  goOfflineSequence: ->
    Spine.trigger "status_changed" , @connectionStatus
    Spine.trigger "show_lightbox" , "showWarning" , error: "Informacion: Esta trabajando sin internet,No podra enviar ni recibir informacion,Cuando se reconecte el sistema se actualizara solo"

  resetSocketSequence: ->
    console.log "Conection Manager Rest " + ciclesCount
    ciclesCount = 0
    Spine.socketManager.handshake()
    Spine.socketManager.subscribe()

  checkOverallStatus: =>
    statusChanged = false
    @cyclesCount++
 
    #A little over an Hour Salesforce Session Expires
    #if @cyclesCount > 380
      #@resetSocketSequence()
 
    if @cyclesCount > 60
      @cyclesCount = 0
      @fetchServerData()
      console.log "CONNECTION MANAGER UPDATE FETCH"
 
    if navigator.onLine and @connectionStatus != "online"
      @connectionStatus = "online"
      statusChanged=true

    else if !navigator.onLine and @connectionStatus == "online"
      @connectionStatus = "offline"
      statusChanged=true

    if statusChanged
      if navigator.onLine then @goOnlineSequence() else @goOfflineSequence()
    
    else if Spine.session?.isExpired() and navigator.onLine
      @refreshSession()

  refreshSession: =>
    if Spine.loggedIn
      Spine.trigger "show_lightbox" , "showWarning" , error: "Su session ha expirado, vamos a cargar la pagina otra vez" , ->
        window.location.reload();
    
  fetchServerData: =>
    for model in Spine.socketModels
      model.query() if model.autoQuery

  fetchLocalData: =>
    Session.fetch()    
    for model in Spine.socketModels
      model.fetch()

    for model in Spine.transitoryModels
      model.fetch()

module.exports = ConnectionManager