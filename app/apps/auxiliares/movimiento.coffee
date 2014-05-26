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

class CreateMovimiento extends Spine.Controller
  @extend Spine.Controller.ViewDelegation
  className: "row-fluid"

  elements:
    ".src_proveedor" : "src_proveedor"    
    ".validatable"        :  "inputs_to_validate"
    ".src_smartProductos" : "src_smartProductos"

  events:
    "click .save"         :  "send"
    "click .cancel"       : "onCancel"
    
  constructor: ->
    super
    @tipo = "EN"
    @isCompra= false
    Producto.reset_current()
    @html require("views/apps/auxiliares/movimiento/layout")(@constructor)
    @smartProductos = new SmartProductos( el: @src_smartProductos , smartItem: SmartItemEntrada , referencia: "a")
    @proveedores = new Proveedores(el: @src_proveedor)
    @renderToggle()

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
  
  after_send: =>
    # Spine.socketManager.pushToFeed("Hice la salida #{@documento.Referencia}")
    @onSuccess?()
    @reset()

  onCancel: =>
    @reset()
    @onCancel?()

  reset: =>
    for item in Movimiento.all()
      item.destroy()
    @proveedores.reset()
    @smartProductos.clear()
    @smartProductos.reset()
    @release()
  

module.exports = CreateMovimiento