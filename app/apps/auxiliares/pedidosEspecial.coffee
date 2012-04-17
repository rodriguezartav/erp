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

  constructor: ->
    super 
    @pedidoItem = PedidoItem.createFromProducto(@producto)
    @html require("views/apps/auxiliares/pedidosEspecial/item")(@pedidoItem) 

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

class PedidosEspecial extends Spine.Controller
  @extend Spine.Controller.ViewDelegation
  
  className: "row-fluid"

  @departamento = "Ventas"
  @label = "Pedidos Especiales"

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

    Producto.bind "current_set" , @addItem
    Cliente.bind "current_set" , @addCliente

    @pedido = Pedido.create( { Referencia: parseInt(Math.random() * 10000) })
    @items = []
    @html require("views/apps/auxiliares/pedidosEspecial/layout")(@pedido)
    @clientes = new Clientes(el: @src_cliente)

    PedidoItem.bind "update" , @onPedidoItemChange

  addCliente: =>
    @pedido.Cliente = Cliente.current.id

  addItem: =>
    pedidos = PedidoItem.findAllByAttribute( "Producto" , Producto.current.id )
    return false if pedidos.length > 0
    return false if Producto.current.InventarioActual == 0
    item = new Items(producto: Producto.current)
    @items.push item
    @items_list.append item.el
    @onPedidoItemChange()
    $('a.popable').popover(placement: "bottom")    

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

  customReset: ->
    @clientes.reset()
    PedidoItem.unbind "change update" , @onPedidoItemChange
    
    Producto.unbind "current_set" , @addMovimiento
    for items in @items
      items.reset()
    Producto.reset()
    Cliente.reset()
    @pedido.destroy()
    
  
module.exports = PedidosEspecial