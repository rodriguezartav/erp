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
    @updateFromView( @pagoItem , @inputs_to_validate )
    #@saldos_list.html
    
  reset: =>
    @pagoItem.destroy()
    @saldo = null
    @release()

class Pagos extends Spine.Controller
  @extend Spine.Controller.ViewDelegation
  
  className: "row-fluid pago active"

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
      monto += item.pagoItem.Monto
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

class PagosList extends Spine.Controller

  events:
    "click .pago"         :   "onPagoClick"
    
  elements:
    ".pago"               :   "pagosElements"

  setBindings: =>
    Pago.bind "beforeDestroy" , @onPagoDestroy
    PagoItem.bind "change update" , @onPagoItemChange

  resetBindings: =>
    PagoItem.unbind "change update" , @onPagoItemChange
    Pago.unbind "beforeDestroy" , @onPagoDestroy
 
  constructor: ->
    super
    @pagoToControllerMap= {}
    @setBindings()

  onPagoItemChange: =>
    @currentController?.onPagoItemChange()

  onPagoClick: (e) =>
    codigo = $(e.target).parents(".pago").attr("data-codigo")
    controller = @pagoToControllerMap[codigo]
    @setCurrentController(controller)
    return false;

  createPagoController: (pago) =>
    controller = new Pagos(pago: pago)
    @pagoToControllerMap[pago.Codigo] = controller
    @prepend controller.el
    @setCurrentController(controller)

  setCurrentController: (controller) =>
    @pagosElements.removeClass "active"
    if controller
      @currentController = controller
      @currentController.el.addClass "active"

  onPagoDestroy: (pago) =>
    @pagoToControllerMap[pago.Codigo]  = null
    @setCurrentController(null);

  reset: =>
    @resetBindings()
    @currentController ={}
    @release()


class EmitirRecibo extends Spine.Controller  
  className: "row-fluid listable pagos"

  @departamento = "Credito y Cobro"
  @label = "Emitir Recibos"
  @icon = "icon-shopping-cart"

  elements:
    ".pagos_list"         : "pagos_list"
    ".src_cliente"        : "src_cliente"

  events:
    "click .cancel"       :   "reset"
    "click .reload"       :   "reload"
    "click .createPago"   :   "onClienteSelect"


  setBindings: =>
    Cliente.bind "current_set" , @onClienteSelect

  resetBindings: =>
    Cliente.unbind "current_set" , @onClienteSelect

  constructor: ->
    super
    saldo.destroy() for saldo in Saldo.findAllByAttribute("Saldo",0)

    @html require("views/apps/cuentasPorCobrar/emitirRecibo/layout")(@constructor)
    Cliente.reset()
    @clientes = new Clientes(el: @src_cliente  )
    @pagosList = new PagosList(el: @pagos_list)
    @setBindings()

  reload: =>
    @reset()
    Saldo.destroyAll()
    Saldo.query({ avoidQueryTimeBased: true  , saldo: true})

  onClienteSelect: =>
    throw "Escoja un cliente" if !Cliente.current
    pago = Pago.create( { Codigo: parseInt( Math.random() * 10000 ) , Cliente: Cliente.current.id  })
    @pagosList.createPagoController(pago)

  reset: =>
    @resetBindings()
    for index,controller of @pagoToControllerMap
      controller.reset() if controller

    @pagosList.reset()
    @release()
    @navigate "/apps"

module.exports = EmitirRecibo