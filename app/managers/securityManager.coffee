Spine = require('spine')

Entradas = require("apps/auxiliares/entradas")
Salidas = require("apps/auxiliares/salidas")

#pedidos
Pedidos = require("apps/pedidos/pedidos")

PedidosAprobacionGerencia  = require("apps/pedidos/pedidosAprobacionGerencia")
PedidosAprobacionEspecial  = require("apps/pedidos/pedidosAprobacionEspecial")
PedidosAprobacion          = require("apps/pedidos/pedidosAprobacion")

AprobarNota = require("apps/cuentasPorCobrar/aprobarNota")

Compras = require("apps/auxiliares/compras")

NotasCredito = require("apps/auxiliares/notasCredito")
NotasDebito = require("apps/auxiliares/notasDebito")

EmitirPago = require("apps/auxiliares/emitirPago")

EmitirRecibo = require("apps/cuentasPorCobrar/emitirRecibo")


VerSaldos = require("apps/vistas/verSaldos")
VerRegistros = require("apps/vistas/verRegistros")
VerRegistrosResumen = require("apps/vistas/verRegistrosResumen")


VerCierreDiario = require("apps/vistas/verCierreDiario")

VerCierreMensual = require("apps/vistas/verCierreMensual")


Ajustes  = require("apps/contables/ajustes")
DoCierreMensual = require("apps/contables/doCierreMensual")
DoCierreDiario = require("apps/contables/doCierreDiario")

FacturasImpresion = require("apps/print/facturas")

NotasImpresion = require("apps/print/notas")
DocumentosAnular = require("apps/procesos/documentosAnular")

PagosAnular = require("apps/procesos/pagosAnular")

AjustarNegociacion = require("apps/procesos/ajustarNegociacion")

FacturasProveedor = require("apps/cuentasPorPagar/facturasProveedor")
PagosProveedor = require("apps/cuentasPorPagar/pagosProveedor")

CuentasPorPagarFlujo = require("apps/cuentasPorPagar/cuentasPorPagarFlujo")
CuentasPorPagarAprobacion= require("apps/cuentasPorPagar/cuentasPorPagarAprobacion")
CuentasPorPagarEntrega= require("apps/cuentasPorPagar/cuentasPorPagarEntrega")

NotaCreditoProveedor = require("apps/cuentasPorPagar/notaCreditoProveedor")

TomasInventario = require("apps/procesos/tomasInventario")
ListasPrecio = require("apps/procesos/listasPrecio")


EstadoCuenta = require("apps/print/estadoCuenta")


ClienteAccess = require("apps/asc/clienteAccess")


VerClientes = require("apps/vistas/verClientes")

#FOR PROFILE BASED CONFIGURATION
Movimiento = require("models/movimiento")
Cliente = require("models/cliente")
Producto = require("models/producto")
Saldo = require("models/socketModels/saldo")
FacturaPreparada = require("models/socketModels/facturaPreparada")
PedidoPreparado = require("models/socketModels/pedidoPreparado")

class SecurityManager
  
  constructor: ->
    @profiles = {}
    apps = [ClienteAccess, EstadoCuenta , VerCierreMensual,  VerCierreDiario , DoCierreDiario, DoCierreMensual ,  VerRegistrosResumen , VerRegistros, ListasPrecio,AprobarNota  , TomasInventario , Ajustes ,  NotaCreditoProveedor,PagosAnular , Pedidos , AjustarNegociacion , VerClientes,  Entradas , Salidas  , Compras  , NotasCredito , FacturasProveedor ,CuentasPorPagarFlujo, CuentasPorPagarAprobacion ,PagosProveedor, CuentasPorPagarEntrega , NotasDebito  ,EmitirPago ,FacturasImpresion  , PedidosAprobacion , PedidosAprobacionGerencia , PedidosAprobacionEspecial  , NotasImpresion ,DocumentosAnular ]
    @profiles["Platform System Admin"] = apps
    @profiles["Tesoreria"] = [ AprobarNota , PedidosAprobacionGerencia , PedidosAprobacionEspecial ,  FacturasProveedor , PagosProveedor , DocumentosAnular , NotaCreditoProveedor , VerRegistrosResumen , VerRegistros , AjustarNegociacion ]
    @profiles["Presidencia"] =  [ DoCierreDiario  , AjustarNegociacion ,   Compras , CuentasPorPagarFlujo , CuentasPorPagarAprobacion  , TomasInventario , VerRegistrosResumen  ]
    @profiles["SubGerencia"] =  [ AprobarNota , AjustarNegociacion ,   Compras  , PedidosAprobacionEspecial , CuentasPorPagarFlujo , CuentasPorPagarAprobacion , PedidosAprobacionGerencia , VerRegistrosResumen ]
    @profiles["Ejecutivo Ventas"] = [ Pedidos , FacturasImpresion , VerRegistrosResumen , VerRegistros  , VerClientes ]
    @profiles["Encargado de Ventas"] = [ Pedidos  , FacturasImpresion  , TomasInventario , VerRegistrosResumen , VerRegistros , VerClientes ]
    @profiles["Ejecutivo Credito"] = [ EstadoCuenta , PagosAnular , Entradas,Salidas ,NotasCredito,NotasDebito,EmitirPago,PedidosAprobacion,NotasImpresion ,VerRegistrosResumen , VerRegistros , VerClientes ]
    @profiles["Vendedor"] = [ Pedidos , VerClientes ]
    @profiles["Contabilidad"] = [ Ajustes , VerCierreMensual ,  VerCierreDiario , DoCierreDiario , DoCierreMensual ,CuentasPorPagarFlujo , VerRegistros ,  VerRegistrosResumen ]
    Spine.bind "login_complete" , @onLoginComplete

  onLoginComplete: =>
    Spine.status = "loggedIn"
        
        
    Spine.options =
      locationType : if Spine.session.hasPerfiles(["Vendedor"]) then "Ruta" else "Planta" 
      aprobacion   : if Spine.session.hasPerfiles(["Ejecutivo Credito","Platform System Admin"])  then true else false
      facturacion  : if Spine.session.hasPerfiles(["Recepcion","Encargado Ventas" , "Ejecutivo Ventas","Platform System Admin"]) then true else false

    Movimiento.attributes.push('ProductoCosto') if Spine.session.hasPerfiles(["Platform System Admin" , "Presidencia" , "SubGerencia"])
    
    Cliente.autoReQuery = false
    Producto.autoReQuery = false
    
    Spine.session.updateInterval = 360
    if Spine.session.hasPerfiles([ "Ejecutivo Credito" ])
      Saldo.autoQuery = true
      Cliente.autoQuery = true
      PedidoPreparado.autoQuery    = true
      
    else if Spine.session.hasPerfiles([ "Ejecutivo Ventas" ])
      Producto.autoQuery   = true
      Cliente.autoQuery = true
      FacturaPreparada.autoQuery   = true

    else if Spine.session.hasPerfiles([ "Encargado Ventas" ])
      Producto.autoQuery   = true
      Cliente.autoQuery = true

    else if Spine.session.hasPerfiles([ "Vendedor" ])
      Producto.autoQuery   = true
      Cliente.autoQuery = true
      Saldo.autoQuery = false

    else if Spine.session.hasPerfiles([ "Tesoreria" ])
      Saldo.autoQuery = true
      PedidoPreparado.autoQuery = true

    else if Spine.session.hasPerfiles([ "Presidencia,SubGerencia" ])
      Cliente.autoQuery = true
      Producto.autoQuery = true
      Saldo.autoQuery = true
      PedidoPreparado.autoQuery = true

    else if Spine.session.hasPerfiles([ "Platform System Admin" ])
      Cliente.autoQuery = true
      Producto.autoQuery = true
      Saldo.autoQuery = true
      Saldo.autoReQuery = true

    Spine.session.save()


    Spine.apps = @profiles[Spine.session.user.Perfil]


module.exports = SecurityManager