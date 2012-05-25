Spine = require('spine')
Cliente = require("models/cliente")
Clientes = require("controllers/clientes")
Saldo = require("models/socketModels/saldo")
Pago = require("models/transitory/pago")
PagoItem = require("models/transitory/pagoItem")

class Items extends Spine.Controller  
  @extend Spine.Controller.ViewDelegation
  tag: "tr"

  elements:
    ".validatable" : "inputs_to_validate"

  events:
    "click .incluir" : "add_saldo"
    "click .excluir" : "remove_saldo"
    "change input" : "checkItem"

  constructor: ->
    super
    @pagoItem = PagoItem.createFromDocumento(@saldo)
    @render()
    
  render: =>
    @html require("views/apps/cuentasPorCobrar/emitirRecibo/item")(@pagoItem)

  add_saldo: (e) =>
    @pagoItem.Monto = @pagoItem.Saldo
    @pagoItem.save()
    @render()
    
  remove_saldo: (e) =>
    @pagoItem.Monto = 0
    @pagoItem.save()
    @render()

  checkItem: (e) =>
    @updateFromView(@pagoItem,@inputs_to_validate)
    @saldos_list.html
    
  reset: =>
    @pagoItem.destroy()
    @saldo = null
    @release()

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
    @items = []

  setBindings: =>

  resetBindings: =>

  constructor: ->
    super
    @setVariables()
    @setBindings()
    @html require("views/apps/cuentasPorCobrar/emitirRecibo/pago")(@pago)
    @refreshView(@pago,@inputs_to_validate)
    @el.attr("data-codigo" , @pago.Codigo)
    @renderSaldos()

  renderSaldos: ->
    saldos = Saldo.findAllByAttribute("Cliente",@pago.Cliente)
    saldos.sort (a,b) ->
      return if parseInt(a.Consecutivo) < parseInt(b.Consecutivo) then -1 else 1
      
    for saldo in saldos
      ri = new Items(saldo: saldo)
      @items.push ri
      @saldos_list.append ri.el
    $('.info_popover').popover()

  onPagoItemChange: =>
    monto = 0
    for item in @items
      monto += item.pago.Monto
    @lbl_total.html monto.toMoney()

  close: =>
    @customReset()

  customReset: =>
    @resetBindings()
    for item in @items
      item.reset() if item
    @pago.destroy()
    @setVariables()
    @release()

class EmitirRecibo extends Spine.Controller  
  className: "row-fluid listable pedidos"

  @departamento = "Credito y Cobro"
  @label = "Emitir Recibos"
  @icon = "icon-shopping-cart"

  elements:
    ".list_item"         : "list_item"
    ".src_cliente"       : "src_cliente"

  events:
    "click .cancel"      :  "reset"
    "click .pago"        :  "onPagoClick"
    "click .createPago"  :  "onClienteSelect"

  setVariables: =>
    @pagos = Pago.all()
    @currentController = null
    @pagoControllers = []
    @pagoToControllerMap = {}
    Cliente.reset()

  setBindings: =>
    PagoItem.bind "change update" , @onPagoItemChange
    #Producto.bind "current_set" , @addItem
    Cliente.bind "current_set" , @onClienteSelect
    Pago.bind "beforeDestroy" , @onPagoDestroy

  resetBindings: =>
    PagoItem.unbind "change update" , @onPagoItemChange
    #Producto.unbind "current_set" , @addItem
    Cliente.unbind "current_set" , @onClienteSelect
    Pago.unbind "beforeDestroy" , @onPagoDestroy

  constructor: ->
    super
    
    for saldo in Saldo.all()
      saldo.destroy() if saldo.Saldo == 0
    
    @setVariables()
    @html require("views/apps/cuentasPorCobrar/emitirRecibo/layout")(@constructor)
    @clientes = new Clientes(el: @src_cliente  )
    @setBindings()
    @loadPedido()
 
  loadPedido: =>
    #for pago in @pagos
     # controller = @createPedidoController(pedido)
    #  @setCurrentController(controller)


  onPagoItemChange: =>
    @currentController?.onPagoItemChange()

  onPagoClick: (e) =>
    pagoEl = $(e.target).parents(".pago")
    codigo = pagoEl.attr("data-codigo")
    controller = @pagoToControllerMap[codigo]
    @setCurrentController(controller)
    return false;

  setCurrentController: (controller) =>
    @list_item.removeClass "active"
    if controller
      @currentController = controller
      @currentController.el.addClass "active"

  createPago:  =>
    codigo = parseInt( Math.random() * 10000 )
    pago = Pago.create( { Codigo: codigo , Cliente: Cliente.current.id  })
    @pagos.push pago
    return pago


  onClienteSelect: =>
    throw "Escoja un cliente" if !Cliente.current
    controller = @createPagoController(@createPago())
    @setCurrentController(controller)
    
  createPagoController: (pago) =>
    controller = new Pagos(pago: pago)
    controller.bind ""
    @pagoToControllerMap[pago.Codigo] = controller
    @append controller
    controller

  onPagoDestroy: (pago) =>
    @pagoToControllerMap[pago.Codigo]  = null
    @setCurrentController(null);
    
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