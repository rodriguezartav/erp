require('lib/setup')
Spine = require('spine')
Productos = require("controllers/productos")
Documento = require("models/documento")
Producto = require("models/producto")
MovimientoItem = require("models/transitory/movimiento")
Movimiento = require("models/movimiento")
SmartProductos = require("controllers/smartProductos/smartProductos")
SmartItemEntrada = require("controllers/smartProductos/smartItemEntrada")
Proveedores = require("controllers/proveedores")
Proveedor = require("models/proveedor")
SingleMovimiento = require("apps/auxiliares/movimiento")

class MovimientoLivecycle extends Spine.Controller
  @extend Spine.Controller.ViewDelegation
  className: "row-fluid"

  @departamento = "Inventarios"
  @label = "Movimientos"
  @icon = "icon-arrow-left"

  elements:
    ".panel" : "panel"
    ".create" : "create"    
    ".movimientos_list"   :  "movimientos_list"
    ".list_pendientes" : "list_pendientes"
    ".list_aplicados" : "list_aplicados"

  events:
    "click .btn_create"       : "onCreate"
    "click .item" :       "onItemClick"
    "click .costoInput" : "onInputClick"
    "click .reload"  : "reload"
    "click .btn_bulk" : "onBulkAction"
    "change .costoInput" : "onInputChange"
    
  onInputClick: (e) =>
    target = $(e.target)
    target.select()
    return false;  

  onInputChange: (e) =>
    target = $(e.target)
    movimiento = MovimientoItem.find target.data "id"
    costo = parseFloat(target.val())
    movimiento.ProductoCosto = if costo == NaN or costo == undefined or costo == null then 0 else costo
    movimiento.save()
    target.val movimiento.ProductoCosto;

    return false;

  constructor: ->
    super
    @tipo = "EN"
    @isCompra= false
    Producto.reset_current()
    @html require("views/apps/auxiliares/movimientoLivecycle/layout")(@constructor)
    @reload()

  reload: =>
    MovimientoItem.destroyAll()
    MovimientoItem.ajax().query {livecycle: true } , afterSuccess: @render

  render: =>
    movimientos = MovimientoItem.findAllByAttribute "IsAplicado" , false
    @list_pendientes.html require("views/apps/auxiliares/movimientoLivecycle/item")(MovimientoItem.group_by_boleta(movimientos))

    movimientos = MovimientoItem.findAllByAttribute "IsAplicado" , true
    @list_aplicados.html require("views/apps/auxiliares/movimientoLivecycle/itemAprobado")(MovimientoItem.group_by_boleta(movimientos))

  onCreate: =>
    @panel.hide()
    create = $("<div class='create'></div>")
    @el.append create
    @movimiento.reset() if @singlemovimiento
    @singlemovimiento = new SingleMovimiento 
      el: create
      onSuccess: =>
        @reload()
        @onCreateComplete()
      onCancel: @onCreateComplete

  onCreateComplete: =>
    @panel.show()

  onItemClick: (e) =>
    target = $(e.target)
    target = target.parent() until target.hasClass "item"
    details = target.find(".details")
    status = details.is(":visible")
    @el.find(".details").hide()
    target.find(".details").show() if !status    


  onBulkAction: (e) =>
    target = $(e.target)
    boleta = target.data "boleta"

    movimientos =  MovimientoItem.select (item) =>
      return true if parseInt(item.Referencia) == parseInt(boleta)

    for movimiento in movimientos
      movimiento.ProductoCosto = Producto.find(movimiento.Producto).Costo if !movimiento.ProductoCosto
      movimiento.save()
    
    data =
      class: Movimiento
      restRoute: "Movimiento"
      restMethod: "PUT"
      restData: 
        movimientos: MovimientoItem.salesforceFormat(movimientos,true)
        deleteAction: if target.data("action") == "delete" then true else false

    Spine.trigger "show_lightbox" , "rest" , data , @after_send
  
  after_send: =>
   # Spine.socketManager.pushToFeed("Hice la salida #{@documento.Referencia}")
    @panel.show()
    @create.hide()
    @reload()

  customReset: =>
    @singlemovimiento.reset() if @singlemovimiento
    @navigate "/apps"


module.exports = MovimientoLivecycle