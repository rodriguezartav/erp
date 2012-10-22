Spine = require('spine')
Producto = require("models/producto")
Movimiento = require("models/movimiento")

class SmartItemSalida extends Spine.Controller
  @extend Spine.Controller.ViewDelegation

  tag: "li"

  elements:
    ".validatable"          : "inputs_to_validate"
    ".view"  : "view"
    ".edit"  : "edit"

  events:
    "click .js_btn_remove" : "reset"
    "change input"         : "checkItem"
    "click .view"          : "onEdit"
    "click .btnCancel"     : "onView"
    "click .btnSave"       : "onEditSave"
    "click .btnDelete"     : "onDelete"

  constructor: ->
    super
    @createItem( @producto , @cantidad ) if !@dataItem
    @render()

  validateCreation: =>
    if @producto.InventarioActual == 0 or @producto.InventarioActual - @cantidad < 0
      @reset()
      return false
    
    return true

  render: =>
    @html require("views/controllers/smartProductos/movimientos/listItem")(@dataItem)

  createItem: (producto,cantidad) =>
    @dataItem = Movimiento.create_from_producto(@producto)
    @dataItem.Cantidad= cantidad
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
    @render()
    Spine.trigger "item_edit_ended"

  onDelete: (e) =>
    @reset()
    Spine.trigger "item_deleted" , @producto.id

  checkItem: (e) =>
    @updateFromView(@dataItem,@inputs_to_validate) if e

  updateCantidad: (cantidad) =>
    @dataItem.Cantidad += cantidad if cantidad ==1
    @dataItem.Cantidad = cantidad 
    @save()
    @render()

  reset: =>
    @el.empty()
    @el.remove()
    @dataItem.destroy()
    @release()

module.exports = SmartItemSalida