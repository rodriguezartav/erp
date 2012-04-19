require('lib/setup')
Spine = require('spine')
Producto = require("models/producto")
Movimiento = require("models/movimiento")
Documento = require("models/documento")
Proveedores = require("controllers/proveedores")
Proveedor = require("models/proveedor")



class Movimientos extends Spine.Controller
  @extend Spine.Controller.ViewDelegation
  
  tag: "tr"

  elements:
    ".validatable" : "inputs_to_validate"

  events:
    "click .js_btn_remove" : "reset"
    "change input" : "on_change"
    
  constructor: ->
    super 
    @movimiento = Movimiento.create_from_producto(@producto)
    @html require("views/apps/auxiliares/compras/item")(@movimiento) 
    

  on_change: (e) =>
    @updateFromView(@movimiento,@inputs_to_validate)
    
  reset: ->
    @movimiento.destroy()
    @release()


class Compras extends Spine.Controller
  @extend Spine.Controller.ViewDelegation
  
  className: "row-fluid"

  @departamento = "Inventarios"
  @label = "Compra de Mercaderia"
  @icon = "icon-shopping-cart"

  elements:
    ".movimientos_list" : "movimientos_list"
    ".validatable"     : "inputs_to_validate"
    ".src_proveedor" : "src_proveedor"

  events:
    "click .cancel" : "reset"
    "click .save" : "send"

  constructor: ->
    super
    Producto.reset_current()
    Producto.bind "current_set" , @addMovimiento
    Proveedor.query()
    
    @documento = Documento.create {Tipo_de_Documento: "CO"}    
    Movimiento.destroyAll()
    @movimientos = []

    @html require("views/apps/auxiliares/compras/layout")(@constructor)
    @proveedores = new Proveedores(el: @src_proveedor)

  addMovimiento: =>
    item = new Movimientos(producto: Producto.current)
    @movimientos.push item
    @movimientos_list.append item.el

  customValidation: =>
    @validationErrors.push "Ingrese al menos un producto" if Movimiento.count() == 0
    @validationErrors.push "Escoja el Proveedor" if Proveedor.current == null
    
    
  beforeSend: (object) ->
    for movimiento in Movimiento.all()
      movimiento.Tipo             = object.Tipo_de_Documento
      movimiento.Nombre_Contado   = object.Nombre_Contado
      movimiento.Precio           = 0
      movimiento.Impuesto         = 0
      movimiento.Descuento        = 0
      movimiento.Observacion      = object.Observacion
      movimiento.Referencia       = object.Referencia
      movimiento.Proveedor        = Proveedor.current.id
      movimiento.save()
   
  send: (e) =>
    @updateFromView(@documento,@inputs_to_validate)
    Spine.trigger "show_lightbox" , "sendMovimientos" , Movimiento.all() , @after_send   

  after_send: =>
    @reset(false)

  customReset: ->
    @proveedores.reset()
    Producto.unbind "current_set" , @addMovimiento
    for items in @movimientos
      items.reset()
    @documento.destroy()
    
  
module.exports = Compras