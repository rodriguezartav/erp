require('lib/setup')
Spine = require('spine')

SecurityManager = require("managers/securityManager")
ConnectionManager = require("managers/connectionManager")
NotificationManager = require("managers/notificationManager")
SocketManager = require("managers/socketManager")
StatManager = require("managers/statManager")



Header = require("controllers/header")
Footer = require("controllers/footer")

Lightbox = require("controllers/lightbox")


User = require("models/user")
Cliente = require("models/cliente")
Producto = require("models/producto")
Session = require('models/session')

Menu = require("controllers/menu")


class App extends Spine.Controller
  className: "app"

  constructor: ->
    super
    
    StatManager.registerManager()

    Spine.server = @options.server
    Spine.frontEndServer = @options.frontEndServer

    new Header(el: $("header"))
    new Lightbox(el: $(".lightboxCanvas"))
 
    Spine.security       =  new SecurityManager()
    Spine.connection     =  new ConnectionManager()
    Spine.notifications  =  new NotificationManager()
    Spine.socketManager    =  new SocketManager(Spine.frontEndServer)
    
    
    Spine.trigger "show_lightbox" , "login" , @options , @loginComplete

    @routes
      "/apps": =>
         @currentApp?.reset()
         @currentApp = new Menu(apps: Spine.apps)
         @html @currentApp

      "/apps/:name": (params) =>
        @currentApp?.reset()
        for app in Spine.apps
          @currentApp = app if app.name == params.name
       
        ##STAT    
        StatManager.sendEvent "Used #{@currentApp.name}"
        @currentApp = new @currentApp
        @html @currentApp

  loginComplete: =>
    @navigate "/apps"

module.exports = App
    