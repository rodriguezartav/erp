Spine = require('spine')

MovimientoLivecycle = require("apps/auxiliares/movimientoLivecycle")

#pedidos

PedidosLiveCycle          = require("apps/pedidos/pedidosLiveCycle")


NotasLivecycle = require("apps/cuentasPorCobrar/notasLivecycle")


#Compras = require("apps/auxiliares/compras")

ReciboLivecycle = require("apps/cuentasPorCobrar/reciboLivecycle")

VerSaldos = require("apps/vistas/verSaldos")
VerRegistros = require("apps/vistas/verRegistros")
VerRegistrosResumen = require("apps/vistas/verRegistrosResumen")


VerCierreDiario = require("apps/vistas/verCierreDiario")

VerCierreMensual = require("apps/vistas/verCierreMensual")

Ajustes  = require("apps/contables/ajustes")
DoCierreMensual = require("apps/contables/doCierreMensual")
DoCierreDiario = require("apps/contables/doCierreDiario")

DocumentosAnular = require("apps/procesos/documentosAnular")

PagosAnular = require("apps/procesos/pagosAnular")

AjustarNegociacion = require("apps/procesos/ajustarNegociacion")

FacturasProveedor = require("apps/cuentasPorPagar/facturasProveedor")
PagosProveedor = require("apps/cuentasPorPagar/pagosProveedor")
CuentasLiveCycle = require("apps/cuentasPorPagar/cuentasLiveCycle")
DepositosLivecycle = require("apps/cuentasPorPagar/depositosLivecycle")


TomasInventario = require("apps/procesos/tomasInventario")
ListasPrecio = require("apps/procesos/listasPrecio")

EstadoCuenta = require("apps/print/estadoCuenta")

ClienteAccess = require("apps/asc/clienteAccess")

VerClientes = require("apps/vistas/verClientes")
VerProductos = require("apps/remoto/verProductos")


#FOR PROFILE BASED CONFIGURATION
Movimiento = require("models/movimiento")
Cliente = require("models/cliente")
Producto = require("models/producto")
Saldo = require("models/socketModels/saldo")
FacturaPreparada = require("models/socketModels/facturaPreparada")
PedidoPreparado = require("models/socketModels/pedidoPreparado")
Proveedor = require("models/proveedor")

class SecurityManager
  
  constructor: ->
    @profiles = {}
    apps = [   MovimientoLivecycle  , DepositosLivecycle ,  ReciboLivecycle , NotasLivecycle ,FacturasProveedor , CuentasLiveCycle , VerProductos , VerCierreMensual, EstadoCuenta ,  VerCierreDiario , DoCierreDiario ,  VerRegistrosResumen , VerRegistros, ListasPrecio  , TomasInventario  ,PagosAnular  , AjustarNegociacion , VerClientes ,PagosProveedor   , PedidosLiveCycle ,DocumentosAnular ]
    @profiles["Platform System Admin"] = apps
    @profiles["Presidencia"] =  [ CuentasLiveCycle , MovimientoLivecycle , DoCierreDiario  , AjustarNegociacion    , TomasInventario , VerRegistrosResumen  ]
    @profiles["SubGerencia"] =  [ MovimientoLivecycle , NotasLivecycle , AjustarNegociacion   , PedidosLiveCycle   , VerRegistrosResumen ]
    @profiles["Gerencia Comercial"] = [MovimientoLivecycle , NotasLivecycle , PedidosLiveCycle , FacturasProveedor , PagosProveedor    , CuentasLiveCycle  , DocumentosAnular , TomasInventario , VerRegistrosResumen , VerRegistros , VerClientes , AjustarNegociacion ]
    @profiles["Contabilidad"] = [  VerCierreMensual ,  VerCierreDiario , DoCierreDiario , VerRegistros ,  VerRegistrosResumen ]

    @profiles["Ejecutivo de Cuentas"] = [ CuentasLiveCycle , PedidosLiveCycle ,ReciboLivecycle , DepositosLivecycle , FacturasProveedor , PagosProveedor  , DocumentosAnular ,  VerRegistrosResumen , VerRegistros  ]
    @profiles["Ejecutivo Credito"] = [  NotasLivecycle  ,  CuentasLiveCycle , ReciboLivecycle ,FacturasProveedor , EstadoCuenta , PagosAnular , DocumentosAnular ,PedidosLiveCycle ,VerRegistrosResumen , VerRegistros , VerClientes ]
    @profiles["Ejecutivo de Logistica"] = [ MovimientoLivecycle , ListasPrecio , TomasInventario  , PedidosLiveCycle  , VerRegistrosResumen , VerRegistros  , VerClientes , VerProductos ]
    @profiles["Ejecutivo Ventas"] = [  PedidosLiveCycle  , VerRegistrosResumen , VerRegistros  , VerClientes ]

    @profiles["Vendedor"] = [ PedidosLiveCycle ,ReciboLivecycle ,  VerProductos  , VerClientes ]
    Spine.bind "login_complete" , @onLoginComplete

  onLoginComplete: =>
    Spine.status = "loggedIn"

    Spine.options =
      locationType : if Spine.session.hasPerfiles(["Vendedor"]) then "Ruta" else "Planta" 
      aprobacion   : if Spine.session.hasPerfiles(["Ejecutivo Credito","Platform System Admin"])  then true else false
      facturacion  : if Spine.session.hasPerfiles(["Recepcion","Gerencia Comercial" , "Ejecutivo Ventas","Platform System Admin"]) then true else false

    Cliente.autoReQuery     = false
    Producto.autoReQuery    = false
    
    Spine.session.updateInterval = 360
    if Spine.session.hasPerfiles([ "Ejecutivo Credito" ])
      Saldo.autoQuery            = true if Saldo.count() > 0
      Cliente.autoQuery          = true
      PedidoPreparado.autoQuery  = true
      
    else if Spine.session.hasPerfiles([ "Ejecutivo Ventas" ])
      Producto.autoQuery          = true
      Cliente.autoQuery           = true
      FacturaPreparada.autoQuery  = true

    else if Spine.session.hasPerfiles([ "Ejecutivo de Logistica" ])
      Producto.autoQuery          = true

    else if Spine.session.hasPerfiles([ "Vendedor" ])
      Producto.autoQuery  = true
      Cliente.autoQuery   = true
      Saldo.autoQuery     = true if Saldo.count() > 0

    else if Spine.session.hasPerfiles([ "Ejecutivo de Cuentas" ])
      #Saldo.autoQuery            =  true
      Cliente.autoQuery          =  true
      Producto.autoQuery         =  true
      Proveedor.autoQuery        =  true

    else if Spine.session.hasPerfiles([ "Presidencia,SubGerencia"])
      Cliente.autoQuery         = true
      Producto.autoQuery        = true
      Proveedor.autoQuery       = true
      Movimiento.attributes.push('ProductoCosto') 
      Producto.attributes.push("Costo" , "CostoAnterior") 
      
    else if Spine.session.hasPerfiles([ "Gerencia Comercial" ])
      Cliente.autoQuery         = true
      Producto.autoQuery        = true
      Proveedor.autoQuery        = true

    else if Spine.session.hasPerfiles([ "Platform System Admin" ])
      Cliente.autoQuery         = true
      Producto.autoQuery        = true
      Saldo.autoQuery            = true if Saldo.count() > 0
      #Saldo.autoReQuery         = true
      PedidoPreparado.autoQuery = true
      Proveedor.autoQuery = true
      Movimiento.attributes.push('ProductoCosto') 
      Producto.attributes.push("Costo" , "CostoAnterior") 

      

    Spine.session.save()

    Spine.apps = @profiles[Spine.session.user.Perfil]

module.exports = SecurityManager