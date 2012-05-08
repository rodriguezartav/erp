Spine = require('spine')

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

VerSaldos = require("apps/vistas/verSaldos")

Pedidos = require("apps/auxiliares/pedidos")
PedidosEspecial = require("apps/auxiliares/pedidosEspecial")

PedidosAprobacion = require("apps/procesos/pedidosAprobacion")
RecibosAprobacion = require("apps/procesos/recibosAprobacion")
RecibosConversion = require("apps/procesos/recibosConversion")

#CierresContable = require("apps/contables/cierresContable")
FacturasImpresion = require("apps/print/facturas")

NotasImpresion = require("apps/print/notas")
DocumentosAnular = require("apps/procesos/documentosAnular")
PagosAnular = require("apps/procesos/pagosAnular")

AjustarNegociacion = require("apps/procesos/ajustarNegociacion")

class SecurityManager
  
  constructor: ->
    @profiles = {}
    apps = [ AjustarNegociacion,PagosAnular , Pedidos , VerSaldos ,  Entradas , Salidas , Devoluciones , Compras , PedidosEspecial , NotasCredito , FacturasProveedor , PagosProveedor , NotasDebito  ,EmitirPago ,FacturasImpresion  ,PedidosAprobacion  , NotasImpresion ,DocumentosAnular ]
    @profiles["Platform System Admin"] = apps
    @profiles["Tesoreria"] = [  FacturasProveedor , PagosProveedor ]
    @profiles["Presidencia"] = apps
    @profiles["Gerencia"] = apps
    @profiles["Ejecutivo Ventas"] = [Pedidos , FacturasImpresion , DocumentosAnular]
    @profiles["SubGerencia"] = [Pedidos , FacturasImpresion , DocumentosAnular , AjustarNegociacion ]
    @profiles["Ejecutivo Credito"] = [Compras,Entradas,Salidas,Devoluciones,NotasCredito,NotasDebito,EmitirPago,PedidosAprobacion,NotasImpresion,DocumentosAnular]
    @profiles["Vendedor"] = [Pedidos]
    @profiles["Contabilidad"] = []
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