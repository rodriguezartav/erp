Spine = require('spine')

Entradas = require("apps/auxiliares/entradas")
Salidas = require("apps/auxiliares/salidas")
Reposiciones = require("apps/auxiliares/reposiciones")

#pedidos
Pedidos = require("apps/pedidos/pedidos")
PedidosEspecial = require("apps/pedidos/pedidosEspecial")

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

Ajustes = require("apps/contables/ajustes")

FacturasImpresion = require("apps/print/facturas")

NotasImpresion = require("apps/print/notas")
DocumentosAnular = require("apps/procesos/documentosAnular")
FacturasAnular = require("apps/procesos/facturasAnular")
AjustarCredito = require("apps/procesos/ajustarCredito")


PagosAnular = require("apps/procesos/pagosAnular")

AjustarNegociacion = require("apps/procesos/ajustarNegociacion")

FacturasProveedor = require("apps/cuentasPorPagar/facturasProveedor")
PagosProveedor = require("apps/cuentasPorPagar/pagosProveedor")

CuentasPorPagarFlujo = require("apps/cuentasPorPagar/cuentasPorPagarFlujo")
CuentasPorPagarAprobacion= require("apps/cuentasPorPagar/cuentasPorPagarAprobacion")
CuentasPorPagarEntrega= require("apps/cuentasPorPagar/cuentasPorPagarEntrega")

NotaCreditoProveedor = require("apps/cuentasPorPagar/notaCreditoProveedor")

TomasInventario = require("apps/procesos/tomasInventario")

#FOR PROFILE BASED CONFIGURATION
Movimiento = require("models/movimiento")
Saldo = require("models/socketModels/saldo")

class SecurityManager
  
  constructor: ->
    @profiles = {}
    apps = [ AprobarNota , AjustarCredito , TomasInventario , EmitirRecibo, Ajustes ,  NotaCreditoProveedor, FacturasAnular,AjustarNegociacion,PagosAnular , Pedidos , VerSaldos ,  Entradas , Salidas , Reposiciones  , Compras , PedidosEspecial , NotasCredito , FacturasProveedor ,CuentasPorPagarFlujo, CuentasPorPagarAprobacion ,PagosProveedor, CuentasPorPagarEntrega , NotasDebito  ,EmitirPago ,FacturasImpresion  , PedidosAprobacion , PedidosAprobacionGerencia , PedidosAprobacionEspecial  , NotasImpresion ,DocumentosAnular ]
    @profiles["Platform System Admin"] = apps
    @profiles["Tesoreria"] = [  FacturasProveedor , PagosProveedor , CuentasPorPagarEntrega]
    @profiles["Presidencia"] =  [ AprobarNota , NotaCreditoProveedor  , AjustarNegociacion , PagosAnular ,   Compras  , PedidosAprobacionEspecial , CuentasPorPagarFlujo , CuentasPorPagarAprobacion , PedidosAprobacionGerencia   , DocumentosAnular , TomasInventario ]
    @profiles["SubGerencia"] =  [ AprobarNota , NotaCreditoProveedor  , AjustarNegociacion , PagosAnular ,   Compras  , PedidosAprobacionEspecial , CuentasPorPagarFlujo , CuentasPorPagarAprobacion , CuentasPorPagarEntrega   , PedidosAprobacionGerencia, DocumentosAnular , TomasInventario ]
    @profiles["Ejecutivo Ventas"] = [ Pedidos , FacturasImpresion , FacturasAnular ]
    @profiles["Encargado de Ventas"] = [ Pedidos , PedidosEspecial ,FacturasImpresion , FacturasAnular , TomasInventario  ]
    @profiles["Ejecutivo Credito"] = [ AjustarCredito , Entradas,Salidas,Reposiciones,NotasCredito,NotasDebito,EmitirPago,PedidosAprobacion,NotasImpresion]
    @profiles["Vendedor"] = [Pedidos]
    @profiles["Contabilidad"] = [ CuentasPorPagarFlujo ]
    Spine.bind "login_complete" , @onLoginComplete

  onLoginComplete: =>
    Spine.status = "loggedIn"
    Spine.options =
      locationType : if Spine.session.hasPerfiles(["Vendedor"]) then "Ruta" else "Planta" 
      aprobacion   : if Spine.session.hasPerfiles(["Ejecutivo Credito","Platform System Admin"])  then true else false
      facturacion  : if Spine.session.hasPerfiles(["Recepcion","Encargado Ventas" , "Ejecutivo Ventas","Platform System Admin"]) then true else false
      autoUpdate   : true

    Movimiento.attributes.push('ProductoCosto') if Spine.session.hasPerfiles(["Platform System Admin" , "Presidencia" , "SubGerencia"])
    if Spine.session.hasPerfiles([ "Platform System Admin" , "Ejecutivo Credito" , "Vendedor" ])
      Saldo.autoQuery = true
      Saldo.query({}) 

    Spine.apps = @profiles[Spine.session.user.Perfil__c]

module.exports = SecurityManager