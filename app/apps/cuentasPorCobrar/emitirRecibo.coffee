Spine = require('spine')
Cliente = require("models/cliente")
Clientes = require("controllers/clientes")
Documento = require("models/documento")
Pago = require("models/transitory/pago")
PagoItem = require("models/transitory/pagoItem")

class Pagos extends Spine.Controller
  @extend Spine.Controller.ViewDelegation
  
  className: "row-fluid pago list_item active"

  elements:
    ".alert_box" : "alert_box"
    ".items_list" : "items_list"
    ".src_cliente" : "src_cliente"
    ".validatable" : "inputs_to_validate"
    ".lbl_total" : "lbl_total"

  events:
    "click .close" : "close"
    "click .send" : "send"
    "click .save" : "save"

  setVariables: =>
    @pagoItemToControllerMap = {}
    @pagos = []

  setBindings: =>

  resetBindings: =>

  constructor: ->
    super
    @setVariables()
    @html require("views/apps/cuentasPorPagar/emitirRecibo/pago")(@pago)
    @clientes = new Clientes(el: @src_cliente , cliente: @pago.Cliente )
    @refreshView(@pago,@inputs_to_validate)
    @setBindings()

class EmitirRecibo extends Spine.Controller  
  className: "row-fluid listable pedidos"

  @departamento = "Credito y Cobro"
  @label = "Emitir Recibos"
  @icon = "icon-shopping-cart"

  elements:
    ".list_item" : "list_item"

  events:
    "click .cancel"    :  "reset"
    "click .create"    :  "onCreatePago"
    "click .pago"      :  "onPagoClick"

  setVariables: =>
    @pagos = Pago.all()
    @currentController = null
    @pagoControllers = []
    @pagoToControllerMap = {}
    Producto.reset()
    Cliente.reset()
    
  setBindings: =>
    #PedidoItem.bind "change update" , @onPedidoItemChange
    #Producto.bind "current_set" , @addItem
    Cliente.bind "current_set" , @addCliente
    #Pedido.bind "beforeDestroy" , @onPedidoDestroy

  resetBindings: =>
    #PedidoItem.unbind "change update" , @onPedidoItemChange
    #Producto.unbind "current_set" , @addItem
    Cliente.unbind "current_set" , @addCliente
    #Pedido.unbind "beforeDestroy" , @onPedidoDestroy

  constructor: ->
    super
    @setVariables()
    @html require("views/apps/cuentasPorPagar/emitirRecibo/pago")(@constructor)
    @setBindings()
    @loadPedido()
 
  loadPedido: =>
    #for pago in @pagos
     # controller = @createPedidoController(pedido)
    #  @setCurrentController(controller)

  addCliente: =>
    @currentController.addCliente()

  onPagoItemChange: =>
    @currentController?.onPagoItemChange()

  createPago:(recibo) =>
    codigo = parseInt( Math.random() * 10000 )
    pago = Pago.create( { Codigo: codigo  })
    @pagos.push pago
    return pago

  onPagoClick: (e) =>
    pagoEl = $(e.target).parents(".pago")
    referencia = pedidoEl.attr("data-referencia")
    controller = @pagoToControllerMap[referencia]
    @setCurrentController(controller)
    return false;

  setCurrentController: (controller) =>
    @list_item.removeClass "active"
    if controller
      @currentController = controller
      @currentController.el.addClass "active"

  onPagoDestroy: (pedido) =>
    @pagoToControllerMap[pago.Referencia]  = null
    @setCurrentController(null);

  onCreatePago: =>
    controller = @createPagoController(@createPago())
    @setCurrentController(controller)

  createPagoController: (pago) =>
    controller = new Pagos(pago: pago)
    controller.bind ""
    @pagoToControllerMap[pago.Codigo] = controller
    @append controller
    controller
    
  reset: =>
    @resetBindings()
    for index,controller of @pagoToControllerMap
      if controller
        controller.clientes?.reset()
        controller.resetBindings()
        controller.setVariables()
        controller.release()
    @setVariables()
    @release()
    @navigate "/apps"



module.exports = EmitirRecibo