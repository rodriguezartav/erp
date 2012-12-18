require('lib/setup')
Spine = require('spine')
Producto = require("models/producto")
Cliente = require("models/cliente")
Pago = require("models/transitory/pago")
PagoItem = require("models/transitory/pagoItem")
Clientes = require("controllers/clientes")
SinglePago = require("apps/cuentasPorCobrar/singlePago")    
    
class Recibos extends Spine.Controller
  className: "row-fluid listable recibos"

  @departamento = "Recibos"
  @label = "Digitar Recibos"
  @icon = "icon-shopping-cart"

  elements:
    ".list_item" : "list_item"

  events:
    "click .pago"    : "onPagoClick"
    "click .btn_createPago" : "onCreatePago"

  setVariables: =>
    @pagos = Pago.all()
    @currentController = null
    @pagoControllers = []
    @pagoToControllerMap = {}

  setBindings: =>
    Pago.bind "beforeDestroy" , @onPagoDestroy

  resetBindings: =>
    Pago.unbind "beforeDestroy" , @onPagoDestroy

  constructor: ->
    super
    @setVariables()
    @html require("views/apps/cuentasPorCobrar/recibos/layout")(Recibos)
    @setBindings()
    @loadPago()

  loadPago: =>
    for pago in @pagos
      singlePago = @createPago(pago)
      @setCurrentController(singlePago)

  onCreatePago: =>
    singlePago = new SinglePago()
    @pagoToControllerMap[singlePago.pago.Recibo] = singlePago
    @append singlePago
    singlePago

  createPago: (pago=null) =>
    singlePago = new SinglePago(pago: pago)
    @pagoToControllerMap[singlePago.pago.Recibo] = singlePago
    @append singlePago
    @setCurrentController(singlePago)
    singlePago

  onPagoClick: (e) =>
    pagoEl = $(e.target).parents(".pago")
    referencia = pagoEl.data "referencia"
    singlePago = @pagoToControllerMap[Recibo]
    @setCurrentController(singlePago)
    return true;

  setCurrentController: (controller) =>
    @list_item.removeClass "active"
    @currentController = null
    if controller
      @currentController = controller
      @currentController.el.addClass "active"

  onPagoDestroy: (pago) =>
    delete @pagoToControllerMap[pago.Recibo]
    @setCurrentController(null);

  reset: =>
    @resetBindings()
    for index,controller of @pagoToControllerMap
      controller.minor_reset() if controller
    @setVariables()
    @release()
    @navigate "/apps"
  
module.exports = Recibos