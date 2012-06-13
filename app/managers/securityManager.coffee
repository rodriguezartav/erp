Spine = require('spine')

Entradas = require("apps/auxiliares/entradas")
Salidas = require("apps/auxiliares/salidas")
Reposiciones = require("apps/auxiliares/reposiciones")

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
Cliente = require("models/cliente")
Producto = require("models/producto")
Saldo = require("models/socketModels/saldo")
FacturaPreparada = require("models/socketModels/facturaPreparada")
PedidoPreparado = require("models/socketModels/pedidoPreparado")

class SecurityManager
  
  constructor: ->
    @profiles = {}
    apps = [ AprobarNota , AjustarCredito , TomasInventario , EmitirRecibo, Ajustes ,  NotaCreditoProveedor, FacturasAnular,AjustarNegociacion,PagosAnular , Pedidos ,  Entradas , Salidas , Reposiciones  , Compras  , NotasCredito , FacturasProveedor ,CuentasPorPagarFlujo, CuentasPorPagarAprobacion ,PagosProveedor, CuentasPorPagarEntrega , NotasDebito  ,EmitirPago ,FacturasImpresion  , PedidosAprobacion , PedidosAprobacionGerencia , PedidosAprobacionEspecial  , NotasImpresion ,DocumentosAnular ]
    @profiles["Platform System Admin"] = apps
    @profiles["Tesoreria"] = [ AprobarNota , PedidosAprobacionGerencia , FacturasProveedor , PagosProveedor , CuentasPorPagarEntrega ]
    @profiles["Presidencia"] =  [ AprobarNota , NotaCreditoProveedor  , AjustarNegociacion , PagosAnular ,   Compras  , PedidosAprobacionEspecial , CuentasPorPagarFlujo , CuentasPorPagarAprobacion , PedidosAprobacionGerencia   , DocumentosAnular , TomasInventario ]
    @profiles["SubGerencia"] =  [ AprobarNota , NotaCreditoProveedor  , AjustarNegociacion , PagosAnular ,   Compras  , PedidosAprobacionEspecial , CuentasPorPagarFlujo , CuentasPorPagarAprobacion , CuentasPorPagarEntrega   , PedidosAprobacionGerencia, DocumentosAnular , TomasInventario ]
    @profiles["Ejecutivo Ventas"] = [ Pedidos , FacturasImpresion , FacturasAnular ]
    @profiles["Encargado de Ventas"] = [ Pedidos  ,FacturasImpresion , FacturasAnular , TomasInventario  ]
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

    Movimiento.attributes.push('ProductoCosto') if Spine.session.hasPerfiles(["Platform System Admin" , "Presidencia" , "SubGerencia"])
    
    Cliente.autoReQuery = false
    Producto.autoReQuery = false
    
    Spine.session.updateInterval = 360
    #setting profile based update preferences
    if Spine.session.hasPerfiles([ "Ejecutivo Credito" ])
      Saldo.autoQuery = true
      Saldo.autoReQuery = true
      Cliente.autoQuery = true
      Cliente.autoReQuery = true
      PedidoPreparado.autoQuery    = true
      PedidoPreparado.autoReQuery  = false
      
    else if Spine.session.hasPerfiles([ "Ejecutivo Ventas" ])
      Producto.autoQuery   = true
      Producto.autoReQuery = true
      FacturaPreparada.autoQuery   = true
      Spine.session.updateInterval = 50

    else if Spine.session.hasPerfiles([ "Encargado Ventas" ])
      Producto.autoQuery   = true
      Producto.autoReQuery = true
      Spine.session.updateInterval = 50

    else if Spine.session.hasPerfiles([ "Vendedor" ])
      Producto.autoQuery   = true
      Producto.autoReQuery = true
      Saldo.autoQuery = false
      Spine.session.updateInterval = 50

    else if Spine.session.hasPerfiles([ "Tesoreria" ])
      Saldo.autoQuery = true
      Saldo.autoReQuery = false

    else if Spine.session.hasPerfiles([ "Presidencia,SubGerencia" ])
      Cliente.autoQuery = true
      Producto.autoQuery = true
      Saldo.autoQuery = true
      PedidoPreparado.autoQuery    = true

    else if Spine.session.hasPerfiles([ "Platform System Admin" ])
      Cliente.autoQuery = true
      Producto.autoQuery = true
      Saldo.autoQuery = true
      Saldo.autoReQuery = true
      Spine.session.updateInterval = 50

    #else if Spine.session.hasPerfiles([ "Contabilidad" ])
        
    Spine.session.save()


    Spine.apps = @profiles[Spine.session.user.Perfil__c]

module.exports = SecurityManager