Spine = require('spine')
Cliente = require("models/cliente")
Clientes = require("controllers/clientes")
Saldo = require("models/socketModels/saldo")
Pago = require("models/transitory/pago")
PagoItem = require("models/transitory/pagoItem")

class Pagos extends Spine.Controller
  @extend Spine.Controller.ViewDelegation
  
  className: "row-fluid pago list_item active"

  elements:
    ".alert_box" : "alert_box"
    ".saldos_list" : "saldos_list"
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
    @html require("views/apps/cuentasPorCobrar/emitirRecibo/pago")(@pago)
    @refreshView(@pago,@inputs_to_validate)
    @el.attr("data-codigo" , @pago.Codigo)
    @saldos_list.html require("views/apps/cuentasPorCobrar/emitirRecibo/item")(Saldo.all())
    @setBindings()

  close: =>
    @customReset()

  customReset: =>
    @resetBindings()
    #for index,items of @pedidoItemToControllerMap
      #items.reset() if items
    #item.destroy() for item in PedidoItem.itemsInPedido(@pedido) 
    @pago.destroy()
    @setVariables()
    @release()

class EmitirRecibo extends Spine.Controller  
  className: "row-fluid listable pedidos"

  @departamento = "Credito y Cobro"
  @label = "Emitir Recibos"
  @icon = "icon-shopping-cart"

  elements:
    ".list_item" : "list_item"
    ".src_cliente" : "src_cliente"

  events:
    "click .cancel"    :  "reset"
    "click .createPago"    :  "onCreatePago"
    "click .pago"      :  "onPagoClick"

  setVariables: =>
    @pagos = Pago.all()
    @currentController = null
    @pagoControllers = []
    @pagoToControllerMap = {}
    Cliente.reset()
    
    
  setBindings: =>
    #PedidoItem.bind "change update" , @onPedidoItemChange
    #Producto.bind "current_set" , @addItem
    #Cliente.bind "current_set" , @addCliente
    Pago.bind "beforeDestroy" , @onPagoDestroy

  resetBindings: =>
    #PedidoItem.unbind "change update" , @onPedidoItemChange
    #Producto.unbind "current_set" , @addItem
    #Cliente.unbind "current_set" , @addCliente
    Pago.unbind "beforeDestroy" , @onPagoDestroy

  constructor: ->
    super
    @setVariables()
    @html require("views/apps/cuentasPorCobrar/emitirRecibo/layout")(@constructor)
    @clientes = new Clientes(el: @src_cliente  )
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
    throw "Escoja un cliente" if !Cliente.current
    codigo = parseInt( Math.random() * 10000 )
    pago = Pago.create( { Codigo: codigo , Cliente: Cliente.current.id  })
    @pagos.push pago
    return pago

  onPagoClick: (e) =>
    pagoEl = $(e.target).parents(".pago")
    codigo = pagoEl.attr("data-codigo")
    controller = @pagoToControllerMap[codigo]
    @setCurrentController(controller)
    Cliente.reset_current;
    return false;

  setCurrentController: (controller) =>
    @list_item.removeClass "active"
    if controller
      @currentController = controller
      @currentController.el.addClass "active"

  onPagoDestroy: (pago) =>
    @pagoToControllerMap[pago.Codigo]  = null
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