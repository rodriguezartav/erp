require('lib/setup')
Spine = require('spine')

Lightbox = require("controllers/lightbox")
InfoBar = require("controllers/infoBar")

User = require("models/user")
Cliente = require("models/cliente")
Producto = require("models/producto")
Session = require('models/session')

Menu = require("apps/menu")
Entradas = require("apps/auxiliares/entradas")
Salidas = require("apps/auxiliares/salidas")
Devoluciones = require("apps/auxiliares/devoluciones")
Compras = require("apps/auxiliares/compras")
FacturasProveedor = require("apps/auxiliares/facturasProveedor")
PagosProveedor = require("apps/auxiliares/pagosProveedor")
NotasCredito = require("apps/auxiliares/notasCredito")
NotasDebito = require("apps/auxiliares/notasDebito")
EmitirRecibo = require("apps/auxiliares/emitirRecibo")
ConvertirRecibo = require("apps/auxiliares/convertirRecibo")
CierresContable = require("apps/contables/cierresContable")
DocumentosImpresion = require("apps/procesos/documentosImpresion")
EstadoCuentaCliente = require("apps/procesos/estadoCuentaCliente")


class App extends Spine.Controller
  className: "app"

  constructor: ->
    super
    #Spine.server = if @test then "http://127.0.0.1:9393" else "http://rodco-api2.heroku.com"
    #Spine.server = if @test then "http://127.0.0.1:9393" else "http://api2s.heroku.com"
    #Spine.server = "http://127.0.0.1:9393"
    Spine.server = "http://api2s.heroku.com"
    
    @setup_plugins()
    @fetchLocalData()
    @buildProfiles()
    
    new Lightbox(el: $(".lightboxCanvas"))
    new InfoBar(el: $(".infoBar"))
    
    Spine.trigger "show_lightbox" , "login" , @options , @loginComplete

    @routes
      "/apps": =>
         @currentApp?.reset()
         @currentApp = new Menu(apps: @apps)
         @html @currentApp
     
      "/apps/:name": (params) =>
        @currentApp?.reset()
        for app in @apps
          @currentApp = app if app.name == params.name
        @currentApp = new @currentApp
        @html @currentApp
     
  registerStatusHandler: ->
    Spine.bind "status_changed" , @handleStatus

  handleStatus: (status) ->
    if status == "online" and Spine.session.isExpired()
      Spine.trigger "show_lightbox" , "login" , @options 

  fetchLocalData: =>
    Session.fetch()    
    for model in Spine.nSync
      model.fetch()

    for model in Spine.transitoryModels
      model.fetch()


  fetchServerData: =>
    for model in Spine.nSync
      model.query()

  loginComplete: =>
    @registerStatusHandler()
    @registerApps()   
    @fetchServerData()
    route = if @options.app then "/#{@options.app}" else ""
    @navigate "/apps" + route

  registerApps: =>
    profile = Spine.session.user.Perfil__c
    @apps = Spine.profiles[profile]

  setup_plugins: =>
    $('.dropdown-toggle').dropdown()
    $('a.tipable').tooltip()
    $('a.popable').popover()
    $('#subnav').scrollspy(offset: -100)

  buildProfiles: =>
    profiles = {}
    apps = [Entradas,Salidas,Devoluciones,Compras,FacturasProveedor,PagosProveedor, NotasCredito,NotasDebito,EmitirRecibo,CierresContable , DocumentosImpresion, EstadoCuentaCliente ]
    profiles["Platform System Admin"] = apps
    profiles["Gerencia"] = apps
    Spine.profiles = profiles
    
    

module.exports = App
    