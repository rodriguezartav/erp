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


class MovimientoLivecycle extends Spine.Controller
  @extend Spine.Controller.ViewDelegation
  className: "row-fluid"

  @departamento = "Inventarios"
  @label = "Movimientos"
  @icon = "icon-arrow-left"
  

  className: "row-fluid"

  elements:
    ".panel" : "panel"
    ".create" : "create"
    ".src_proveedor" : "src_proveedor"
    
    ".validatable"        :  "inputs_to_validate"
    ".movimientos_list"   :  "movimientos_list"
    ".src_smartProductos" : "src_smartProductos"
    ".list_pendientes" : "list_pendientes"
    ".list_aplicados" : "list_aplicados"

  events:
    "click .save"         :  "send"
    "click .btn_create"       : "onCreate"
    "click .cancel"       : "onCancel"
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
    @smartProductos = new SmartProductos( el: @src_smartProductos , smartItem: SmartItemEntrada , referencia: "a")
    @proveedores = new Proveedores(el: @src_proveedor)
    @renderToggle()
    @reload()

  reload: =>
    MovimientoItem.destroyAll()
    MovimientoItem.ajax().query {livecycle: true } , afterSuccess: @render

  render: =>
    movimientos = MovimientoItem.findAllByAttribute "IsAplicado" , false
    @list_pendientes.html require("views/apps/auxiliares/movimientoLivecycle/item")(MovimientoItem.group_by_boleta(movimientos))

    movimientos = MovimientoItem.findAllByAttribute "IsAplicado" , true
    @list_aplicados.html require("views/apps/auxiliares/movimientoLivecycle/itemAprobado")(MovimientoItem.group_by_boleta(movimientos))


  renderToggle: =>
    @el.find('.entrada_toogle').toggleButtons
      width: 200,
      label:
        enabled: "Entrada"
        disabled: "Salida"
      onChange: ($el, status, e) =>
        @tipo = if status then "EN" else "SA"
        return true

     @el.find('.compra_toogle').toggleButtons
        width: 100,
        label:
          enabled: "Si"
          disabled: "No"
        onChange: ($el, status, e) =>
          @isCompra = status
          return true

  onCreate: =>
    @panel.hide()
    @create.show()    
    @inputs_to_validate.val ""
    @smartProductos.clear()

  onCancel: =>
    @panel.show()
    @create.hide()

  onItemClick: (e) =>
    target = $(e.target)
    target = target.parent() until target.hasClass "item"
    details = target.find(".details")
    status = details.is(":visible")
    @el.find(".details").hide()
    target.find(".details").show() if !status    

  customValidation: =>
    @validationErrors.push "Ingrese al menos un producto" if Movimiento.count() == 0
    @validationErrors.push "Escoja el Proveedor" if @el.find(".js_proveedor_search").val().length == 0

  beforeSend: (object) ->
    for movimiento in Movimiento.all()
      movimiento.Tipo             = if @isCompra then "CO" else @tipo
      movimiento.Nombre_Contado   = @el.find(".js_proveedor_search").val()
      movimiento.Precio           = 0
      movimiento.Impuesto         = 0
      movimiento.Descuento        = 0
      movimiento.SubTotal         = 0
      movimiento.Observacion      = object.Observacion
      movimiento.Referencia       = object.Referencia
      movimiento.save()
      object.Observacion = ""
    
  send: (e) =>
    @updateFromView({},@inputs_to_validate)
    
    data =
      class: Movimiento
      restRoute: "Movimiento"
      restMethod: "POST"
      restData: 
        movimientos: Movimiento.salesforceFormat( Movimiento.all(), false ) 

    Spine.trigger "show_lightbox" , "rest" , data , @after_send
  
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
    for item in Movimiento.all()
      item.destroy()
    @smartProductos.reset()
    @navigate "/apps"
    
  

module.exports = MovimientoLivecycle