require('lib/setup')
Spine = require('spine')
Producto = require("models/producto")
Cliente = require("models/cliente")
Pedido = require("models/transitory/pedido")
PedidoItem = require("models/transitory/pedidoItem")

Clientes = require("controllers/clientes")

class Items extends Spine.Controller
  @extend Spine.Controller.ViewDelegation
  
  tag: "tr"

  elements:
    ".validatable" : "inputs_to_validate"

  events:
    "click .js_btn_remove" : "reset"
    "change input" : "on_change"
    "click input" : "on_click"

  constructor: ()->
    super
    @createItem(@producto,@referencia) if @producto
    @html require("views/apps/auxiliares/pedidos/item")(@pedidoItem) 

  createItem: (producto,referencia) =>
    @pedidoItem = PedidoItem.createFromProducto(@producto)
    @pedidoItem.Referencia = referencia
    @pedidoItem.save()

  on_click: (e) =>
    $(e).select()

  on_change: (e) =>
    @updateFromView(@pedidoItem,@inputs_to_validate)
    @pedidoItem.updateSubTotal()
    @pedidoItem.applyDescuento()
    @pedidoItem.applyImpuesto()
    @pedidoItem.updateTotal()

  reset: ->
    @pedidoItem.destroy()
    @release()

#################
## CONTADO
################

class Credito extends Spine.Controller
  @extend Spine.Controller.ViewDelegation
  
  className: "row-fluid pedido list_item active"

  elements:
    ".alert_box" : "alert_box"
    ".items_list" : "items_list"
    ".src_cliente" : "src_cliente"
    ".error" : "error"
    ".validatable" : "inputs_to_validate"
    ".lbl_subTotal" : "lbl_subTotal"
    ".lbl_descuento" : "lbl_descuento"
    ".lbl_impuesto" : "lbl_impuesto"
    ".lbl_total" : "lbl_total"
    ".nombre" : "nombre"

  events:
    "click .close" : "close"
    "click .send" : "send"
    "click .save" : "save"

  setVariables: =>
    @pedidoItemToControllerMap = {}

  setBindings: =>
    PedidoItem.bind "beforeDestroy" , @onPedidoItemDestroy

  resetBindings: =>
    PedidoItem.unbind "beforeDestroy" , @onPedidoItemDestroy

  constructor: ->
    super
    @setVariables()
    @html require("views/apps/auxiliares/pedidos/credito")(@pedido) if !@pedido.IsContado
    @html require("views/apps/auxiliares/pedidos/contado")(@pedido) if @pedido.IsContado
    @clientes = new Clientes(el: @src_cliente , cliente: @pedido.Cliente , contado: @pedido.IsContado)
    
    @refreshView(@pedido,@inputs_to_validate)
    
    @loadPedidoItems()
    @el.attr("data-referencia" , @pedido.Referencia)
    @setBindings()
    
  loadPedidoItems: =>
    items = PedidoItem.itemsInPedido(@pedido)
    for pedidoItem in items
      item = new Items(pedidoItem: pedidoItem)
      @registerItem(item)

  addCliente: =>
    return false if !@el.hasClass "active"
    @pedido.Cliente = Cliente.current.id
    @pedido.save()

  addItem: =>
    return false if PedidoItem.isProductoInPedido(Producto.current,@pedido.Referencia)
    return false if Producto.current.InventarioActual == 0

    ##KMQ REVENUE
    _kmq.push(['record', 'Added to Cart', {'Producto': Producto.current.Name }] ) ;
    item = new Items(producto: Producto.current , referencia: @pedido.Referencia)
    @registerItem(item)
    
  registerItem: (item) =>
    @items_list.append item.el
    @onPedidoItemChange()
    @pedidoItemToControllerMap[item.pedidoItem.id] =  item
    $('a.popable').popover(placement: "bottom")    
    
  onPedidoItemDestroy: (pedidoItem) =>
    @pedidoItemToControllerMap[pedidoItem.id] = null
    
  onPedidoItemChange: =>
    @pedido.updateFromPedidoItems(PedidoItem.itemsInPedido(@pedido))
    @pedido.save()
    @lbl_subTotal.html @pedido.SubTotal.toMoney()
    @lbl_descuento.html @pedido.Descuento.toMoney()
    @lbl_impuesto.html @pedido.Impuesto.toMoney()
    @lbl_total.html @pedido.Total.toMoney()
    
  customValidation: =>
    @validationErrors.push "Ingrese el Nombre del Cliente" if @pedido.Cliente == null and !@pedido.IsContado
    @validationErrors.push "Ingrese al menos un producto" if PedidoItem.itemsInPedido(@pedido).length == 0
    
  beforeSend: (object) ->
    nombre = @el.find('.nombre').val()
    for pi in PedidoItem.itemsInPedido(object)
      pi.Cliente = object.Cliente if object.Cliente
      pi.Referencia = object.Referencia
      pi.Orden = object.Orden
      pi.Fuente = Spine.session.type
      pi.Observacion = object.Observacion
      pi.IsContado = object.IsContado
      pi.Transporte = object.Transporte
      pi.Estado = "Pendiente"
      if object.IsContado
        pi.Nombre = nombre
        pi.Telefono = object.Telefono
        pi.Identificacion = object.Identificacion
        pi.Email = object.Email
      pi.save()
    
  save: (e = null)=>
    @updateFromView(@pedido,@inputs_to_validate)
    @pedido.save()
    @alert_box.html require("views/alert")(message: "Listo! Se han guardado los cambios..")
    window.setTimeout => 
      @alert_box.empty()  
    , 1400

  send: (e) =>
    @save()
    @log PedidoItem.itemsInPedido(@pedido)
    Spine.trigger "show_lightbox" , "sendPedidos" , PedidoItem.itemsInPedido(@pedido) , @after_send   

  after_send: =>
    _kmq.push(['record', 'Purchased', {'Amount': @pedido.Total } ]);
    @customReset()

  close: =>
    ##KMQ REVENUEW
    _kmq.push(['record', 'Canceled', {'Amount': @pedido.Total } ]);
    @customReset()

  customReset: =>
    @resetBindings()
    @clientes.reset()
    for index,items of @pedidoItemToControllerMap
      items.reset() if items
    item.destroy() for item in PedidoItem.itemsInPedido(@pedido) 
    @pedido.destroy()
    @setVariables()
    @release()

#################
## PEDIDOS CLASS
################
    
class Pedidos extends Spine.Controller
  className: "row-fluid listable"

  @departamento = "Ventas"
  @label = "Digitar Pedidos"

  elements:
    ".list_item" : "list_item"

  events:
    "click .cancel"    : "reset"
    "click .credito"   : "onCredito"
    "click .contado"   : "onContado"
    "click .pedido"    : "onPedidoClick"

  setVariables: =>
    @pedidos = Pedido.all()
    @currentController = null
    @pedidoControllers = []
    @pedidoToControllerMap = {}

  setBindings: =>
    PedidoItem.bind "change update" , @onPedidoItemChange
    Producto.bind "current_set" , @addItem
    Cliente.bind "current_set" , @addCliente
    Pedido.bind "beforeDestroy" , @onPedidoDestroy

  resetBindings: =>
    PedidoItem.unbind "change update" , @onPedidoItemChange
    Producto.unbind "current_set" , @addItem
    Cliente.unbind "current_set" , @addCliente
    Pedido.unbind "beforeDestroy" , @onPedidoDestroy

  constructor: ->
    super
    @setVariables()

    Producto.reset()
    Cliente.reset()

    @html require("views/apps/auxiliares/pedidos/layout")(Pedidos)
    @setBindings()
    
    @loadPedido()
 
  loadPedido: =>
    for pedido in @pedidos
      controller = @createPedidoController(pedido)
      @setCurrentController(controller)

  addCliente: =>
    @currentController.addCliente()
    
  addItem: =>
    @currentController.addItem()
    
  onPedidoItemChange: =>
    @currentController?.onPedidoItemChange()

  createPedido: (contado=false) =>
    ref = parseInt(Math.random() * 10000)
    pedido = Pedido.create( { Referencia: ref , Tipo_de_Documento: "FA" , IsContado: contado })
    @pedidos.push pedido
    return pedido

  onPedidoClick: (e) =>
    pedidoEl = $(e.target).parents(".pedido")
    referencia = pedidoEl.attr("data-referencia")
    controller = @pedidoToControllerMap[referencia]
    @setCurrentController(controller)
    return false;

  setCurrentController: (controller) =>
    @list_item.removeClass "active"
    if controller
      @currentController = controller
      @currentController.el.addClass "active"

  onPedidoDestroy: (pedido) =>
    @pedidoToControllerMap[pedido.Referencia]  = null
    @setCurrentController(null);

  onCredito: =>
    controller = @createPedidoController(@createPedido())
    @setCurrentController(controller)
    
  onContado: =>
    controller = @createPedidoController(@createPedido(true))
    @setCurrentController(controller)

  createPedidoController: (pedido) =>
    ##KMQ REVENUE
    _kmq.push(['record', 'Started Purchase', {'Contado': pedido.IsContado } ]);
    controller = new Credito(pedido: pedido)
    controller.bind ""
    @pedidoToControllerMap[pedido.Referencia] = controller
    @append controller
    controller
    
  reset: =>
    @resetBindings()
    for index,controller of @pedidoToControllerMap
      if controller
        controller.clientes?.reset()
        controller.resetBindings()
        controller.setVariables()
        controller.release()
    @setVariables()
    @release()
    @navigate "/apps"
  
module.exports = Pedidos