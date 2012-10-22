Spine = require('spine')
Producto = require("models/producto")
PedidoItem = require("models/transitory/dataItem")

class SmartItemInterface extends Spine.Controller
  @extend Spine.Controller.ViewDelegation

  tag: "li"

  elements:
    ".validatable"          : "inputs_to_validate"
    ".view"  : "view"
    ".edit"  : "edit"

  events:
    "click .js_btn_remove" : "reset"
    "change input"         : "checkItem"
    "click input"          : "on_click"
    "click .precio"        : "onPrecioClick"
    "click .view"          : "onEdit"
    "click .btnCancel"     : "onView"
    "click .btnSave"       : "onEditSave"
    "click .btnDelete"     : "onDelete"
    "change .especialValue" : "onEspecialValueChange"

  constructor: ->
    super
    @createItem( @producto , @cantidad , @referencia ) if !@dataItem
    @render()

  validate: =>
    if @producto.InventarioActual == 0 or @producto.InventarioActual - @cantidad < 0
      @reset()
      return false

    if PedidoItem.itemsInPedido({Referencia: @referencia}).length > 10
      alert "Hay mas de 10 productos en la lista"
      @reset()
      return false
      
    return true

  render: =>
    @html require("views/controllers/smartProductos/pedido/listItem")(@dataItem)

  createItem: (producto,cantidad) =>
    @dataItem = ""
    @dataItem.save()

  onEdit: (e) =>
    @edit.show()
    @view.hide()
    Spine.trigger "item_edit_started"

  onEditSave: (e) =>
    @onView()

  onView: (e) =>
    @edit.hide()
    @view.show()
    Spine.trigger "item_edit_ended"

  onDelete: (e) =>
    @reset()
    Spine.trigger "item_deleted" , @producto.id

  reset: =>
    @el.empty()
    @el.remove()
    @dataItem.destroy()
    @release()

module.exports = SmartItemInterface