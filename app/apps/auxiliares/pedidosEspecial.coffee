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
    "change input" : "checkItem"
    "click input" : "on_click"

  constructor: ->
    super 
    @pedidoItem = PedidoItem.createFromProducto(@producto)
    @html require("views/apps/auxiliares/pedidosEspecial/item")(@pedidoItem) 

  on_click: (e) =>
    $(e).select()

  checkItem: (e) =>
    @updateFromView(@pedidoItem,@inputs_to_validate)
    @pedidoItem.updateSubTotal()
    @pedidoItem.applyDescuento()
    @pedidoItem.applyImpuesto()
    @pedidoItem.updateTotal()

  reset: =>
    @pedidoItem.destroy()
    @release()

class PedidosEspecial extends Spine.Controller
  @extend Spine.Controller.ViewDelegation
  
  className: "row-fluid"

  @departamento = "Ventas"
  @label = "Pedidos Especiales"
  @icon = "icon-key"

  elements:
    ".items_list" : "items_list"
    ".src_cliente" : "src_cliente"
    ".error" : "error"
    ".validatable" : "inputs_to_validate"
    ".lbl_subTotal" : "lbl_subTotal"
    ".lbl_descuento" : "lbl_descuento"
    ".lbl_impuesto" : "lbl_impuesto"
    ".lbl_total" : "lbl_total"

  events:
    "click .cancel" : "reset"
    "click .save" : "send"

  constructor: ->
    super
    Producto.reset()
    Cliente.reset()


    @pedido = Pedido.create( { Referencia: parseInt(Math.random() * 10000) })
    @items = []
    @itemToControllerMap = {}
    
    @html require("views/apps/auxiliares/pedidosEspecial/layout")(@pedido)
    @clientes = new Clientes(el: @src_cliente)

    @setBindings()

  setBindings: =>
    Producto.bind "current_set" , @addItem
    Cliente.bind "current_set" , @addCliente
    
    PedidoItem.bind "beforeDestroy" , @removeItem
    PedidoItem.bind "update" , @onPedidoItemChange
    

  resetBindings: =>
    PedidoItem.unbind "beforeDestroy" , @removeItem
    PedidoItem.unbind "change" , @onPedidoItemChange
    Cliente.unbind "current_set" , @addCliente
    
    Producto.unbind "current_set" , @addMovimiento
    

  addCliente: =>
    @pedido.Cliente = Cliente.current.id

  addItem: =>
    pedidos = PedidoItem.findAllByAttribute( "Producto" , Producto.current.id )
    return false if pedidos.length > 0
    return false if Producto.current.InventarioActual == 0
    item = new Items(producto: Producto.current)
    @items.push item
    @itemToControllerMap[item.pedidoItem.id] = item
    @items_list.append item.el
    @onPedidoItemChange()
    $('a.popable').popover(placement: "bottom")    

  removeItem: (item) =>
    item = @itemToControllerMap[item.id]
    index = @items.indexOf(item)
    @items.splice(index,1)
    @itemToControllerMap[item.id] = null

  onPedidoItemChange: =>
    @pedido.updateFromPedidoItems(PedidoItem.all())
    @pedido.save()
    @lbl_subTotal.html @pedido.SubTotal.toMoney()
    @lbl_descuento.html @pedido.Descuento.toMoney()
    @lbl_impuesto.html @pedido.Impuesto.toMoney()
    @lbl_total.html @pedido.Total.toMoney()
    
  customValidation: =>
    @validationErrors.push "Ingrese el Nombre del Cliente" if Cliente.current == null
    @validationErrors.push "Ingrese al menos un producto" if PedidoItem.count() == 0
    item.checkItem() for item in @items
    
  beforeSend: (object) ->
    for pi in PedidoItem.all()
      pi.Cliente = object.Cliente
      pi.Referencia = object.Referencia
      pi.Fuente = Spine.session.type
      pi.Observacion = object.Observacion
      pi.Estado = "Pendiente"
      pi.save()
    
  send: (e) =>
    @updateFromView(@pedido,@inputs_to_validate)
    Spine.trigger "show_lightbox" , "sendPedidos" , PedidoItem.itemsInPedido(@pedido) , @after_send   

  after_send: =>
    @reset(false)

  customReset: =>
    @clientes.reset()
    for items in @items
      items?.reset()
    Producto.reset()
    Cliente.reset()
    @resetBindings()
    @pedido.destroy()
    
  
module.exports = PedidosEspecial