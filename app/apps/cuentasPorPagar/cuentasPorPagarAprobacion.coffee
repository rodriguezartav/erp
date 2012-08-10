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
    CuentaPorPagar.bind "query_success" , @renderCuentas
    @reload()

  reload: ->
    CuentaPorPagar.query({ estado: "'Para Aprobar'" , orderFechaVencimiento: true })    

  renderCuentas: =>
    cuentas = CuentaPorPagar.all()
    @srcCuentas.html require("views/apps/cuentasPorPagar/cuentasPorPagarAprobacion/item")(cuentas)
    @el.find('.info_popover').popover({placement: "top"})

      
  onSend: (e) =>
    target = $(e.target)
    @cuenta = CuentaPorPagar.find(target.attr("data-id"))
    @cuenta.Estado = "Para Pagar"
    @cuenta.save()    
    cuentaSf = CuentaPorPagar.toSalesforce(@cuenta)

    data =
      class: CuentaPorPagar
      restRoute: "Tesoreria"
      restMethod: "POST"
      restData: JSON.stringify( { "cuentas" :  [ cuentaSf ] } )

    Spine.trigger "show_lightbox" , "rest" , data , @onAprobarSuccess


  onAprobarSuccess: =>
    Spine.socketManager.pushToFeed( "Aprobe una CXP de #{@cuenta.NombreProveedor}")

    Spine.throttle ->
      Spine.socketManager.pushToProfile("Tesoreria" , "Aprobe algunas CXP, pueden proceeder a pagarlos.")
    , 15000
    
    
    @cuenta.destroy()
    @renderCuentas()

  reset: ->
    CuentaPorPagar.unbind "query_success" , @onLoadPedidos
    @release()
    @navigate "/apps"

module.exports = CuentasPorPagarAprobacion