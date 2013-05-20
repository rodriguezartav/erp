Spine = require('spine')

MovimientoLivecycle = require("apps/auxiliares/movimientoLivecycle")

#pedidos
PedidosLiveCycle          = require("apps/pedidos/pedidosLiveCycle")
EntregasLiveCycle          = require("apps/pedidos/entregasLiveCycle")

NotasLivecycle = require("apps/cuentasPorCobrar/notasLivecycle")
DocumentoLivecycle = require("apps/cuentasPorCobrar/documentoLivecycle")

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


AjustarNegociacion = require("apps/procesos/ajustarNegociacion")

FacturasProveedor = require("apps/cuentasPorPagar/facturasProveedor")
PagosProveedor = require("apps/cuentasPorPagar/pagosProveedor")
CuentasLiveCycle = require("apps/cuentasPorPagar/cuentasLiveCycle")
DepositosLivecycle = require("apps/cuentasPorPagar/depositosLivecycle")


TomasInventario = require("apps/procesos/tomasInventario")
ListasPrecio = require("apps/procesos/listasPrecio")

EstadoCuenta = require("apps/print/estadoCuenta")

ClienteAccess = require("apps/asc/clienteAccess")


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
    apps = [ DocumentoLivecycle ,  EntregasLiveCycle , MovimientoLivecycle  , DepositosLivecycle ,  ReciboLivecycle , NotasLivecycle , CuentasLiveCycle , VerProductos , VerCierreMensual, EstadoCuenta ,  VerCierreDiario , DoCierreDiario ,  VerRegistrosResumen , VerRegistros, ListasPrecio  , TomasInventario  , AjustarNegociacion  ,PagosProveedor   , PedidosLiveCycle ,DocumentosAnular ]
    @profiles["Platform System Admin"] = apps
    @profiles["IT"] = apps

    @profiles["Presidencia"] =  [ CuentasLiveCycle , MovimientoLivecycle , DoCierreDiario  , VerProductos , PedidosLiveCycle , AjustarNegociacion    , TomasInventario , VerRegistrosResumen  ]
    @profiles["SubGerencia"] =  [ MovimientoLivecycle , NotasLivecycle , AjustarNegociacion , VerProductos , PedidosLiveCycle   , VerRegistrosResumen ]
    @profiles["Gerencia Comercial"] = [MovimientoLivecycle , NotasLivecycle , PedidosLiveCycle , VerProductos  , PagosProveedor    , CuentasLiveCycle  , DocumentosAnular , TomasInventario , VerRegistrosResumen , VerRegistros  , AjustarNegociacion ]
    @profiles["Contabilidad"] = [  VerCierreMensual ,  VerCierreDiario , DoCierreDiario , VerRegistros ,  VerRegistrosResumen ]


    @profiles["Tesoreria"] = [MovimientoLivecycle , VerProductos  , PagosProveedor  , CuentasLiveCycle ]


    @profiles["Ejecutivo de Cuentas"] = [ CuentasLiveCycle , EstadoCuenta , PedidosLiveCycle , VerProductos ,ReciboLivecycle , DepositosLivecycle , FacturasProveedor , PagosProveedor  , DocumentosAnular ,  VerRegistrosResumen , VerRegistros  ]
    @profiles["Ejecutivo Credito"] = [  NotasLivecycle  ,  CuentasLiveCycle , ReciboLivecycle , VerProductos ,FacturasProveedor , EstadoCuenta  , DocumentosAnular ,PedidosLiveCycle ,VerRegistrosResumen , VerRegistros  ]
    @profiles["Ejecutivo de Logistica"] = [ EntregasLiveCycle , MovimientoLivecycle , ListasPrecio , VerProductos , TomasInventario  , DocumentosAnular , PedidosLiveCycle  , VerRegistrosResumen , VerRegistros   , VerProductos ]
    @profiles["Ejecutivo Ventas"] = [  PedidosLiveCycle  , EntregasLiveCycle  , ReciboLivecycle , VerRegistrosResumen , VerProductos , VerRegistros   ]
    @profiles["Coordinador"] = [ PedidosLiveCycle , EntregasLiveCycle ,ReciboLivecycle ,  VerProductos   , VerProductos ]
    @profiles["Vendedor"] = [ PedidosLiveCycle , EntregasLiveCycle ,ReciboLivecycle ,  VerProductos   ]
    Spine.bind "login_complete" , @onLoginComplete

  onLoginComplete: =>
    Spine.status = "loggedIn"

    Spine.options =
      locationType : if Spine.session.hasPerfiles(["Vendedor"]) then "Ruta" else "Planta" 
      aprobacion   : if Spine.session.hasPerfiles(["Ejecutivo Credito","Platform System Admin"])  then true else false
      facturacion  : if Spine.session.hasPerfiles(["Recepcion","Gerencia Comercial" , "Ejecutivo Ventas","Platform System Admin"]) then true else false

    Cliente.autoReQuery     = false
    Producto.autoReQuery    = false
    Spine.session.updateInterval = 1360

    if Spine.session.hasPerfiles([ "Ejecutivo Credito" ])
      Saldo.autoQuery            = true
      Cliente.autoQuery          = true
      Producto.autoQuery          = true
      PedidoPreparado.autoQuery  = true
      
    else if Spine.session.hasPerfiles([ "Ejecutivo Ventas" ])
      Producto.autoQuery          = true
      Cliente.autoQuery           = true
      FacturaPreparada.autoQuery  = true

    else if Spine.session.hasPerfiles([ "Ejecutivo de Logistica" ])
      Cliente.autoQuery           = true
      Producto.autoQuery          = true

    else if Spine.session.hasPerfiles([ "Vendedor" ])
      Producto.autoQuery  = true
      Cliente.autoQuery   = true
      Saldo.autoQuery     = true

    else if Spine.session.hasPerfiles([ "Ejecutivo de Cuentas" ])
      Cliente.autoQuery          =  true
      Producto.autoQuery         =  true
      Saldo.autoQuery            =  true

    else if Spine.session.hasPerfiles([ "Presidencia", "SubGerencia" ])
      Cliente.autoQuery         = true
      Producto.autoQuery        = true
      Proveedor.autoQuery       = true
      Movimiento.attributes.push('ProductoCosto') 
      Producto.attributes.push("Costo" , "CostoAnterior" , "UtilidadVenta") 
      
    else if Spine.session.hasPerfiles([ "Gerencia Comercial" ])
      Cliente.autoQuery         = true
      Producto.autoQuery        = true
      Proveedor.autoQuery       = true

    else if Spine.session.hasPerfiles([ "Platform System Admin" ])
      Cliente.autoQuery         = true
      Producto.autoQuery        = true
      Saldo.autoQuery           = true
      PedidoPreparado.autoQuery = true
      Proveedor.autoQuery = true
      Movimiento.attributes.push('ProductoCosto') 
      Producto.attributes.push("Costo" , "CostoAnterior") 

    else if Spine.session.hasPerfiles([ "IT" ])
      Cliente.autoQuery         = true
      Producto.autoQuery        = true

    Spine.session.save()

    Spine.apps = @profiles[Spine.session.user.Perfil]

module.exports = SecurityManager