require('lib/setup')
Spine = require('spine')

SecurityManager = require("managers/securityManager")
ConnectionManager = require("managers/connectionManager")
NotificationManager = require("managers/notificationManager")
FayeManager = require("managers/fayeManager")



Header = require("controllers/header")
Footer = require("controllers/footer")

Lightbox = require("controllers/lightbox")


User = require("models/user")
Cliente = require("models/cliente")
Producto = require("models/producto")
Session = require('models/session')

Menu = require("apps/menu")


class App extends Spine.Controller
  className: "app"

  constructor: ->
    super
    Spine.server = "http://127.0.0.1:9393"
    #Spine.server = "http://api2s.heroku.com"

    new Header(el: $("header"))
    new Lightbox(el: $(".lightboxCanvas"))
 
    Spine.security       =  new SecurityManager()
    Spine.connection     =  new ConnectionManager()
    Spine.notifications  =  new NotificationManager()
    Spine.fayeManager    =  new FayeManager()
    
    
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
       
        ##KMQ    
        _kmq.push(['record', 'App ' + @currentApp.name + ' Started' ]);
        @currentApp = new @currentApp
        @html @currentApp

  loginComplete: =>
    @navigate "/apps"

module.exports = App
    