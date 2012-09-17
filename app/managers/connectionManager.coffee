Spine = require('spine')
Session = require('models/session')
User = require('models/user')
Cliente = require('models/cliente')

class ConnectionManager

  constructor: ->
    @fetchLocalData()
    Spine.bind "login_complete" , @fetchServerData
    window.setInterval( @checkOverallStatus , 1000000 )

  checkOverallStatus: =>
    @fetchServerData()

    if Spine.session?.isExpired() and navigator.onLine
      Spine.trigger "show_lightbox" , "showWarning" , error: "Su session ha expirado, vamos a cargar la pagina otra vez" , ->
        window.location.reload();

  fetchServerData: () =>
    if navigator.onLine
      for model in Spine.socketModels
        model.ajax().query( {} ) if model.autoQuery

  fetchLocalData: =>
    try
      Session.fetch()    
      for model in Spine.socketModels
        model.fetch()

      for model in Spine.transitoryModels
        model.fetch()

    catch e
      

module.exports = ConnectionManager