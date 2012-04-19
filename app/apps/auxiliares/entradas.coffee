require('lib/setup')
Spine = require('spine')
Productos = require("controllers/productos")
Documento = require("models/documento")
Producto = require("models/producto")
Movimiento = require("models/movimiento")

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
    @html require("views/apps/auxiliares/entradas/item")(@movimiento)
  
  on_change: (e) =>
    @updateFromView(@movimiento,@inputs_to_validate)
    
  reset: ->
    @movimiento.destroy()
    @release()
    

class Entradas extends Spine.Controller
  @extend Spine.Controller.ViewDelegation
  className: "row-fluid"

  @departamento = "Inventarios"
  @label = "Entradas de Mercaderia"
  @icon = "icon-arrow-right"
  

  className: "row-fluid"

  elements:
    ".error"              :  "error"
    ".validatable"        :  "inputs_to_validate"
    ".movimientos_list"   :  "movimientos_list"

  events:
    "click .cancel"       :  "reset"
    "click .save"         :  "send"

  constructor: ->
    super
    Producto.reset_current()
    Producto.bind "current_set" , @addMovimiento
    Movimiento.destroyAll()
    @movimientos = []

    @documento = Documento.create {Tipo_de_Documento: "EN"}
    @html require("views/apps/auxiliares/entradas/layout")(@constructor)
    @error.hide()

  addMovimiento: =>
    item = new Movimientos(producto: Producto.current)
    @movimientos.push item
    @movimientos_list.append item.el

  customValidation: =>
    @validationErrors.push "Ingrese al menos un producto" if Movimiento.count() == 0
    
  beforeSend: (object) ->
    for movimiento in Movimiento.all()
      movimiento.Tipo             = object.Tipo_de_Documento
      movimiento.Nombre_Contado   = object.Nombre_Contado
      movimiento.Precio           = 0
      movimiento.Impuesto         = 0
      movimiento.Descuento        = 0
      movimiento.SubTotal         = 0
      movimiento.Observacion      = object.Observacion
      movimiento.Referencia       = object.Referencia
      movimiento.save()
    
  send: (e) =>
    @updateFromView(@documento,@inputs_to_validate)
    Spine.trigger "show_lightbox" , "sendMovimientos" , Movimiento.all() , @after_send   

  after_send: =>
    @reset()

  customReset: ->
   for items in @movimientos
      items.reset()
    @documento.destroy()
    Producto.unbind "current_set" , @addMovimiento
    
  

module.exports = Entradas