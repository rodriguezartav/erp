require('lib/setup')
Spine = require('spine')

Lightbox = require("controllers/lightbox")
Header = require("controllers/header")

Timer = require("timer")

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
EmitirPago = require("apps/auxiliares/emitirPago")


Pedidos = require("apps/auxiliares/pedidos")
PedidosEspecial = require("apps/auxiliares/pedidosEspecial")

PedidosAprobacion = require("apps/procesos/pedidosAprobacion")
RecibosAprobacion = require("apps/procesos/recibosAprobacion")
RecibosConversion = require("apps/procesos/recibosConversion")

CierresContable = require("apps/contables/cierresContable")
DocumentosImpresion = require("apps/procesos/documentosImpresion")
NotasImpresion = require("apps/procesos/notasImpresion")

DocumentosAnular = require("apps/procesos/documentosAnular")



class App extends Spine.Controller
  className: "app"

  constructor: ->
    super
    #Spine.server = if @test then "http://127.0.0.1:9393" else "http://rodco-api2.heroku.com"
    #Spine.server = if @test then "http://127.0.0.1:9393" else "http://api2s.heroku.com"
    #Spine.server = "http://127.0.0.1:9393"
    Spine.server = "http://api2s.heroku.com"
    
    Timer.registerTimers()
    Spine.followNavigatorStatus()
    Spine.status = navigator.onLine
    
    @setup_plugins()
    @fetchLocalData()
    @buildProfiles()

    new Header(el: $("header"))
    new Lightbox(el: $(".lightboxCanvas"))
    
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
       
        ##KMQ    
        _kmq.push(['record', 'App ' + @currentApp.name + ' Started' ]);
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
      if model.autoQuery
        model.query()

  loginComplete: =>
    @registerStatusHandler()
    @registerApps()   
    @fetchServerData()
    route = if @options.app then "/#{@options.app}" else ""
    @navigate "/apps" + route

  registerApps: =>
    profile = Spine.session.user.Perfil__c
    Spine.session.type = if profile == "Vendedor" then "Ruta" else "Planta" 
    @apps = Spine.profiles[profile]

  setup_plugins: =>
    $('.dropdown-toggle').dropdown()
    $('a.tipable').tooltip()
    $('a.popable').popover()
    $('#subnav').scrollspy(offset: -100)

  buildProfiles: =>
    profiles = {}
    apps = [ Pedidos , Entradas , Salidas , Devoluciones , Compras , PedidosEspecial , NotasCredito , FacturasProveedor , PagosProveedor , NotasDebito , CierresContable ,EmitirPago ,DocumentosImpresion  ,PedidosAprobacion  , NotasImpresion ,DocumentosAnular ]
    profiles["Platform System Admin"] = apps
    profiles["Tesoreria"] = [  FacturasProveedor , PagosProveedor  , CierresContable  ]
    profiles["Presidencia"] = apps
    profiles["Gerencia"] = apps
    profiles["Ejecutivo Ventas"] = [Pedidos,PedidosEspecial,DocumentosImpresion]
    profiles["Ejecutivo Credito"] = [Entradas,Salidas,Compras,NotasCredito,NotasDebito,EmitirPago,PedidosAprobacion,NotasImpresion,DocumentosAnular]
    profiles["Vendedor"] = [Pedidos]
    profiles["Contabilidad"] = [CierresContable]
    profiles["Facturacion"] = apps
    
    Spine.profiles = profiles

module.exports = App
    