Spine = require('spine')
Session = require('models/session')
Lightbox = require("controllers/lightbox")


class ConnectionManager

  constructor: ->

    @connectionStatus= "online"
    @startupSequence()
    Spine.bind "login_complete" , @loginSequence
    window.setInterval( @checkOverallStatus , 10000 )

  startupSequence: ->
    @fetchLocalData()

  updateSequence: ->
    @fetchServerData()

  loginSequence: =>
    @updateSequence()

  goOnlineSequence: ->
    if Spine.session.isExpired()
      @refreshSession()
    else
      Spine.trigger "show_lightbox" , "showWarning" , error: "Informacion: Regreso el Internet, Continue Normalmente"
      @updateSequence()
      Spine.notifications.fayeManager.connect()

  goOfflineSequence: ->
    Spine.trigger "show_lightbox" , "showWarning" , error: "Informacion: Esta trabajando sin internet,No podra enviar ni recibir informacion,Cuando se reconecte el sistema se actualizara solo"

  checkOverallStatus: =>
    statusChanged = false
 
    if navigator.onLine and @connectionStatus != "online"
      @connectionStatus = "online"
      statusChanged=true

    else if !navigator.onLine and @connectionStatus == "online"
      @connectionStatus = "offline"
      statusChanged=true

    if statusChanged
      Spine.trigger "status_changed" , @connectionStatus
      if navigator.onLine then @goOnlineSequence() else @goOfflineSequence()
    
    else if Spine.session?.isExpired() and navigator.onLine
      @refreshSession()

  refreshSession: =>
    if Spine.loggedIn
      Spine.trigger "show_lightbox" , "showWarning" , error: "Su session ha expirado, vamos a cargar la pagina otra vez" , ->
        window.location.reload();
    
  fetchServerData: =>
    for model in Spine.nSync
      if model.autoQuery
        model.query()

  fetchLocalData: =>
    Session.fetch()    
    for model in Spine.nSync
      model.fetch()

    for model in Spine.transitoryModels
      model.fetch()
  

module.exports = ConnectionManager