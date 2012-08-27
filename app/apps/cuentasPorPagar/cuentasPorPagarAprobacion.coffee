require('lib/setup')
Spine = require('spine')
CuentaPorPagar = require("models/transitory/cuentaPorPagar")

class CuentasPorPagarAprobacion extends Spine.Controller
  className: "row-fluid"

  @departamento = "Tesoreria"
  @label = "Aprobacion de Pago"
  @icon = "icon-ok-sign"

  elements:
    ".srcCuentas" : "srcCuentas" 
    ".error"      : "error"
    ".lblTotal"  : "lblTotal"
    ".saldo"      : "saldos"

  events:
    "click .cancel"   : "reset"
    "click .aprobar"     : "onSend"
    "click .reload"   : "reload"

  constructor: ->
    super
    @html require("views/apps/cuentasPorPagar/cuentasPorPagarAprobacion/layout")(CuentasPorPagarAprobacion)
    @reload()

  reload: ->
    CuentaPorPagar.destroyAll()
    CuentaPorPagar.ajax().query({ estado: "'Para Aprobar'" , orderFechaVencimiento: true } , afterSuccess: @renderCuentas)    

  renderCuentas: =>
    cuentas = CuentaPorPagar.all()
    @srcCuentas.html require("views/apps/cuentasPorPagar/cuentasPorPagarAprobacion/item")(cuentas)
    @el.find('.info_popover').popover({placement: "top"})


  onSend: (e) =>
    target = $(e.target)
    @cuenta = CuentaPorPagar.find(target.attr("data-id"))
    @cuenta.Estado = "Para Pagar"
    @cuenta.save()    

    Spine.trigger "show_lightbox" , "update" , @cuenta , @onAprobarSuccess


  onAprobarSuccess: =>
    Spine.throttle ->
      Spine.socketManager.pushToProfile("Tesoreria" , "Aprobe algunas CXP, pueden proceeder a pagarlos.")
    , 15000

    @cuenta.destroy()
    @renderCuentas()

  reset: ->
    @release()
    @navigate "/apps"

module.exports = CuentasPorPagarAprobacion