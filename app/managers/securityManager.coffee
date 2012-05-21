Spine = require('spine')

Entradas = require("apps/auxiliares/entradas")
Salidas = require("apps/auxiliares/salidas")
Reposiciones = require("apps/auxiliares/reposiciones")

#SalidasDanadas = require("apps/auxiliares/salidasDanadas")

#DevolucionesDanadas = require("apps/auxiliares/devolucionesDanadas")

Compras = require("apps/auxiliares/compras")

NotasCredito = require("apps/auxiliares/notasCredito")
NotasDebito = require("apps/auxiliares/notasDebito")

EmitirPago = require("apps/auxiliares/emitirPago")

VerSaldos = require("apps/vistas/verSaldos")

Pedidos = require("apps/auxiliares/pedidos")
PedidosEspecial = require("apps/auxiliares/pedidosEspecial")

PedidosAprobacion = require("apps/procesos/pedidosAprobacion")

FacturasImpresion = require("apps/print/facturas")

NotasImpresion = require("apps/print/notas")
DocumentosAnular = require("apps/procesos/documentosAnular")
FacturasAnular = require("apps/procesos/facturasAnular")

PagosAnular = require("apps/procesos/pagosAnular")

AjustarNegociacion = require("apps/procesos/ajustarNegociacion")

FacturasProveedor = require("apps/cuentasPorPagar/facturasProveedor")
PagosProveedor = require("apps/cuentasPorPagar/pagosProveedor")

CuentasPorPagarFlujo = require("apps/cuentasPorPagar/cuentasPorPagarFlujo")
CuentasPorPagarAprobacion= require("apps/cuentasPorPagar/cuentasPorPagarAprobacion")
CuentasPorPagarEntrega= require("apps/cuentasPorPagar/cuentasPorPagarEntrega")

NotaCreditoProveedor = require("apps/cuentasPorPagar/notaCreditoProveedor")



class SecurityManager
  
  constructor: ->
    @profiles = {}
    apps = [  NotaCreditoProveedor, FacturasAnular,AjustarNegociacion,PagosAnular , Pedidos , VerSaldos ,  Entradas , Salidas , Reposiciones  , Compras , PedidosEspecial , NotasCredito , FacturasProveedor ,CuentasPorPagarFlujo, CuentasPorPagarAprobacion ,PagosProveedor, CuentasPorPagarEntrega , NotasDebito  ,EmitirPago ,FacturasImpresion  ,PedidosAprobacion  , NotasImpresion ,DocumentosAnular ]
    @profiles["Platform System Admin"] = apps
    @profiles["Tesoreria"] = [  FacturasProveedor , PagosProveedor , CuentasPorPagarEntrega]
    @profiles["Presidencia"] =  [ NotaCreditoProveedor  , AjustarNegociacion , PagosAnular ,   Compras , PedidosEspecial , CuentasPorPagarFlujo , CuentasPorPagarAprobacion , PedidosAprobacion   , DocumentosAnular ]
    @profiles["SubGerencia"] =  [ NotaCreditoProveedor  , AjustarNegociacion , PagosAnular ,   Compras , PedidosEspecial , CuentasPorPagarFlujo , CuentasPorPagarAprobacion , CuentasPorPagarEntrega   , PedidosAprobacion, DocumentosAnular ]
    @profiles["Ejecutivo Ventas"] = [Pedidos , FacturasImpresion , FacturasAnular ]
    @profiles["Encargado de Ventas"] = [Pedidos , FacturasImpresion , FacturasAnular  ]
    @profiles["Ejecutivo Credito"] = [Entradas,Salidas,Reposiciones,NotasCredito,NotasDebito,EmitirPago,PedidosAprobacion,NotasImpresion]
    @profiles["Vendedor"] = [Pedidos]
    @profiles["Contabilidad"] = [ CuentasPorPagarFlujo ]
    Spine.bind "login_complete" , @onLoginComplete

  onLoginComplete: =>
    profile = Spine.session.user.Perfil__c
    Spine.status = "loggedIn"
    Spine.options =
      locationType : if profile == "Vendedor" then "Ruta" else "Planta" 
      aprobacion   : if profile.indexOf("Credito") > -1 then true else false
      facturacion  : if profile == "Recepcion" or profile.indexOf("Ventas") then true else false

    Spine.options.aprobacion = true if profile == "Platform System Admin"
    Spine.options.facturacion = true if profile == "Platform System Admin"

    Spine.apps= @profiles[profile]

module.exports = SecurityManager