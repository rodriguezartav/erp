require('lib/setup')
Spine = require('spine')
CuentaPorPagar = require("models/transitory/cuentaPorPagar")

class CuentasPorPagarEntrega extends Spine.Controller
  className: "row-fluid"

  @departamento = "Tesoreria"
  @label = "Entrega de Cheques"
  @icon = "icon-envelope"

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
    @html require("views/apps/cuentasPorPagar/cuentasPorPagarEntrega/layout")(CuentasPorPagarEntrega)
    @reload()

  reload: ->
    CuentaPorPagar.ajax().query({ estado: "'Preparado'" , orderFechaVencimiento: true } ,  afterSuccess: @renderCuentas )        

  renderCuentas: =>
    cuentas = CuentaPorPagar.all()
    @srcCuentas.html require("views/apps/cuentasPorPagar/cuentasPorPagarEntrega/item")(cuentas)
    @el.find('.info_popover').popover({placement: "top"})

      
  onSend: (e) =>
    target = $(e.target)
    @cuenta = CuentaPorPagar.find(target.attr("data-id"))
    @cuenta.Estado = "Entregado"
    @cuenta.save()    
    cuentaSf = CuentaPorPagar.toSalesforce(@cuenta)

    data =
      class: CuentaPorPagar
      restRoute: "Tesoreria"
      restMethod: "POST"
      restData: cuentas: cuentaSf

    Spine.trigger "show_lightbox" , "rest" , data , @onAprobarSuccess


  onAprobarSuccess: =>
    @cuenta.destroy()
    @renderCuentas()

  reset: ->
    @release()
    @navigate "/apps"

module.exports = CuentasPorPagarEntrega