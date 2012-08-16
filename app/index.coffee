require('lib/setup')
Spine = require('spine')

SecurityManager = require("managers/securityManager")
ConnectionManager = require("managers/connectionManager")
NotificationManager = require("managers/notificationManager")
SocketManager = require("managers/socketManager")
StatManager = require("managers/statManager")

Header = require("controllers/header")
Productos = require("controllers/productos")
Footer = require("controllers/footer")

Lightbox = require("controllers/lightbox")

User = require("models/user")
Cliente = require("models/cliente")
Producto = require("models/producto")
User = require("models/user")

Session = require('models/session')

Menu = require("controllers/menu")

class App extends Spine.Controller
  className: "app"

  constructor: ->
    super
    
    #StatManager.registerManager(@options.statApi)

    Spine.server = @options.server
    Spine.pusherKeys = @options.pusherKeys
    Spine.registerParse @options.parseKeys

    new Header(el: $("header"))
    new Productos(el: $(".productosToolbar"))
    
    new Footer(el: $("footer")) 
    new Lightbox(el: $(".lightboxCanvas"))

    Spine.security       =  new SecurityManager()
    Spine.connection     =  new ConnectionManager()
    Spine.notifications  =  new NotificationManager()
    Spine.socketManager  =  new SocketManager(Spine.frontEndServer)
    Spine.statManager    =  StatManager
    Spine.statManager.registerManager(@options.statApi)

    Spine.trigger "show_lightbox" , "login" , @options , @loginComplete

    @routes
      "/apps": =>
        @currentApp?.reset()
        @currentApp = new Menu(apps: Spine.apps)
        @el.removeClass "container"
        @el.addClass "container-fluid"
        @html @currentApp

      "/apps/:label": (params) =>
        @currentApp?.reset()
        for app in Spine.apps
          @currentApp = app if app.label.replace(/\s/g,'') == params.label

        ##STAT    
        StatManager.sendEvent "Used #{@currentApp.name}"
        @currentApp = new @currentApp
        @html @currentApp
        @el.addClass "container"
        @el.removeClass "container-fluid"

  loginComplete: =>
    Spine.statManager.identify Spine.session.user.Name
    Spine.clicked = false


    setInterval =>
      return Spine.clicked = false if Spine.clicked or Spine.paused
      @navigate "/apps"
    , 60000

    #TODO CHANGE VAR NAME AND MOVE
    $("body").click =>
      Spine.clicked = true
      
    $(".appCanvas").click =>
      Spine.trigger "appClick"
      
    @navigate "/apps"


  #TODO PUT SOMEWHERE ELSE
  Spine.throttle= (fn,delay) ->
    clearTimeout(Spine.throttleTimer) if Spine.throttleTimer
    Spine.throttleTimer = setTimeout =>
      console.log arguments
      fn.apply(@, arguments);
    , delay


  Spine.setCookie= (c_name,value,exdays) ->
    exdate=new Date();
    exdate.setDate(exdate.getDate() + exdays);
    c_value=escape(value)
    document.cookie=c_name + "=" + c_value
  


module.exports = App