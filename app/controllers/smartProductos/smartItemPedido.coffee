Spine = require('spine')
Producto = require("models/producto")
PedidoItem = require("models/transitory/pedidoItem")

class SmartItemPedido extends Spine.Controller
  @extend Spine.Controller.ViewDelegation

  tag: "li"

  elements:
    ".validatable"          : "inputs_to_validate"
    ".data-current-precio"  : "data_current_precio"
    ".view"  : "view"
    ".edit"  : "edit"
    ".txtPrecio" : "txtPrecio"

  events:
    "click .js_btn_remove" : "reset"
    "change input"         : "checkItem"
    "click .view"          : "onEdit"
    "click .btnCancel"     : "onView"
    "click .btnSave"       : "onEditSave"
    "click .btnDelete"     : "onDelete"
    "change .especialValue" : "onEspecialValueChange"
    "click .selectPrecio" : "onSelectedPrecio"

  constructor: ->
    super
    @createItem( @producto , @cantidad , @referencia ) if !@dataItem
    @checkItem()
    @render()

  getNegociacion: (negociaciones) =>
    @negociacion = Negociacion.getFromProducto(@producto , negociaciones)
    @dataItem.Descuento = @negociacion.Descuento
    @dataItem.save()

  validateCreation: =>
    if @producto.InventarioActual == 0 or @producto.InventarioActual - @cantidad < 0
      @reset()
      return false

    items = PedidoItem.itemsInPedido( { Referencia: @referencia } )
    if items.length > 10
      alert "Hay mas de 10 productos en la lista"
      @reset()
      return false
    return true

  render: =>
    @html require("views/controllers/smartProductos/pedido/listItem")(@dataItem)

  createItem: (producto,cantidad,referencia,especial=false) =>
    @dataItem = PedidoItem.createFromProducto(@producto)
    @dataItem.Referencia = referencia
    @dataItem.Especial = especial
    @dataItem.Cantidad= cantidad
    @dataItem.save()

  onPedidoItemChange: ->
    @render()
    @checkItem()

  onEspecialValueChange: (e) =>
    @dataItem.Especial = true;
    @dataItem.save()

  onSelectedPrecio: (e) =>
    target = $(e.target)
    precio = parseFloat(target.attr("data-precio"))
    @dataItem.Precio = precio;
    @dataItem.save()
    @checkItem()
    @txtPrecio.val precio

  onEdit: (e) =>
    @edit.show()
    @view.hide()
    Spine.trigger "item_edit_started"

  onEditSave: (e) =>
    @onView()

  onView: (e) =>
    @edit.hide()
    @view.show()
    @render()
    Spine.trigger "item_edit_ended"

  onDelete: (e) =>
    @reset()
    Spine.trigger "item_deleted" , @producto.id

  checkItem: (e) =>
    @updateFromView(@dataItem,@inputs_to_validate) if e
    @dataItem.updateSubTotal()
    @dataItem.applyDescuento()
    @dataItem.applyImpuesto()
    @dataItem.updateTotal()
    @dataItem.isEspecial(@producto)

  updateCantidad: (cantidad) =>
    @dataItem.Cantidad += cantidad if cantidad ==1
    @dataItem.Cantidad = cantidad 
    @checkItem(null)
    @render()

  reset: =>
    @el.empty()
    @el.remove()
    @dataItem.destroy()
    @release()

module.exports = SmartItemPedido