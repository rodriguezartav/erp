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

Devolucion = require("")

class MovimientoLivecycle extends Spine.Controller
  @extend Spine.Controller.ViewDelegation
  className: "row-fluid"

  @departamento = "Inventarios"
  @label = "Movimientos"
  @icon = "icon-retweet"

  elements:
    ".panel"               :   "panel"
    ".create"              :   "create"    
    ".movimientos_list"    :   "movimientos_list"
    ".list_pendientes"     :   "list_pendientes"
    ".list_aplicados"      :   "list_aplicados"

  events:
    "click .btn_create"       : "onCreate"
    "click .item" :       "onItemClick"
    "click input" : "onInputClick"
    "click .reload"  : "reload"
    "click .btn_bulk" : "onBulkAction"
    "change .costoInput" : "onInputChange"
    "change .observacionInput": "onObservacionChange"

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
    console.log movimientos
    movimientos = movimientos.sort (a,b) =>
      return b.Referencia - a.Referencia

    movimientos = MovimientoItem.group_by_boleta(movimientos)

    for movimiento in movimientos
      movimiento.Movimientos.sort (a,b) =>
        return Producto.find(a.Producto).CodigoExterno - Producto.find(b.Producto).CodigoExterno

    @list_pendientes.html require("views/apps/auxiliares/movimientoLivecycle/item")(movimientos)

    movimientos = MovimientoItem.findAllByAttribute "IsAplicado" , true
    movimientos = movimientos.sort (a,b) =>
      return b.Referencia - a.Referencia

    @list_aplicados.html require("views/apps/auxiliares/movimientoLivecycle/itemAprobado")(MovimientoItem.group_by_boleta(movimientos))

  onCreate: =>
    @panel.hide()
    create = $("<div class='create'></div>")
    @el.prepend create
    @singlemovimiento.reset() if @singlemovimiento
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

  onInputChange: (e) =>
    target = $(e.target)
    movimiento = MovimientoItem.find target.data "id"
    costo = parseFloat(target.val())
    movimiento.ProductoCosto = if costo == NaN or costo == undefined or costo == null then 0 else costo
    movimiento.save()
    target.val movimiento.ProductoCosto;
    return false;

  onInputClick: (e) =>
    target = $(e.target)
    target.select()
    return false;  

  onObservacionChange: (e) =>
    target = $(e.target)
    movimiento = MovimientoItem.find target.data "id"
    movimiento.Observacion = target.val()
    movimiento.save()
    return false;

  onBulkAction: (e) =>
    target = $(e.target)
    boleta = target.data "boleta"
    action = target.data("action")
    
    movimientos =  MovimientoItem.select (item) =>
      return true if parseInt(item.Referencia) == parseInt(boleta)
  
    for movimiento in movimientos
      if movimiento.Tipo == "CO" and ( !movimiento.ProductoCosto or movimiento.ProductoCosto == 0 ) and action != "delete"
        # In case this is an CO and costo was not assigned
        costo = Producto.find(movimiento.Producto).Costo
        throw "Error: No se encuentra costo para el producto y este no se ingreso" if !costo or costo == 0
        movimiento.ProductoCosto = costo;
        movimiento.save()

    data =
      class: Movimiento
      restRoute: "Movimiento"
      restMethod: "PUT"
      restData: 
        movimientos: MovimientoItem.salesforceFormat(movimientos,true)
        deleteAction: action == "delete"

    Spine.trigger "show_lightbox" , "rest" , data , @after_send

  after_send: =>
    #Spine.socketManager.pushToFeed("Hice la salida #{@documento.Referencia}")
    @panel.show()
    @create.hide()
    @reload()

  customReset: =>
    @singlemovimiento.reset() if @singlemovimiento
    @navigate "/apps"

module.exports = MovimientoLivecycle