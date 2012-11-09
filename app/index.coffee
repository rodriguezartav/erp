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

Cliente = require("models/cliente")
Producto = require("models/producto")
User = require("models/user")
Proveedor = require("models/proveedor")

Session = require('models/session')

Main = require("controllers/main")

class App extends Spine.Controller
  className: "app"

  constructor: ->
    super
    @navigate "/"

    Spine.server = @options.server
    Spine.pusherKeys = @options.pusherKeys
    Spine.registerParse @options.parseKeys
    User.refresh @options.users

    Proxino.key = "R4f9M9v5r63OtGW62AeHbw"
    Proxino.track_errors();

    new Header(el: $("header"))
    #new Productos(el: $(".productosToolbar"))
    
    new Footer(el: $("footer")) 
    new Lightbox(el: $(".lightboxCanvas"))
    new Main(el: $(".appCanvas") )
    Spine.Route.setup()
    
    Spine.security       =  new SecurityManager()
    Spine.connection     =  new ConnectionManager()
    Spine.notifications  =  new NotificationManager()
    Spine.socketManager  =  new SocketManager(Spine.frontEndServer)
    Spine.statManager    =  StatManager
    Spine.statManager.registerManager(@options.statApi)

    Spine.trigger "show_lightbox" , "authLogin" , @options , @loginComplete

  loginComplete: =>
    Spine.statManager.identify Spine.session.user.Name
    Spine.clicked = false
    @navigate "/apps"

    #setInterval =>
      #return Spine.clicked = false if Spine.clicked or Spine.paused
      #@navigate "/apps"
    #, 60000

    #TODO CHANGE VAR NAME AND MOVE
    #@el.bind "click" , =>
      #Spine.clicked = true
      

  #TODO PUT SOMEWHERE ELSE
  Spine.throttle= (fn,delay) ->
    clearTimeout(Spine.throttleTimer) if Spine.throttleTimer
    Spine.throttleTimer = setTimeout =>
      fn.apply(@, arguments);
    , delay


  Spine.setCookie= (c_name,value,exdays) ->
    exdate=new Date();
    exdate.setDate(exdate.getDate() + exdays);
    c_value=escape(value)
    document.cookie=c_name + "=" + c_value
  
  showUpdating: =>
    Spine.trigger "show_lightbox" , "showWait"
    $(".progress>.bar").css "width" , "100%"

module.exports = App