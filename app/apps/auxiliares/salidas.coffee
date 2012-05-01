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
    "change input" : "checkItem"
    
  constructor: ->
    super
    @movimiento = Movimiento.create_from_producto(@producto)
    @html require("views/apps/auxiliares/salidas/item")(@movimiento)
  
  checkItem: (e) =>
    @updateFromView(@movimiento,@inputs_to_validate)
    
  reset: ->
    @movimiento.destroy()
    @release()
    

class Salidas extends Spine.Controller
  @extend Spine.Controller.ViewDelegation

  @departamento = "Inventarios"
  @label = "Salida de Mercaderia"
  @icon = "icon-arrow-left"


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
    Movimiento.destroyAll()
    @movimientos = []
    @itemToControllerMap= []

    @documento = Documento.create {Tipo_de_Documento: "SA"}
    @html require("views/apps/auxiliares/salidas/layout")(@constructor)
    @error.hide()
    @setBindings()

  setBindings: =>
    Producto.bind "current_set" , @addMovimiento
    Movimiento.bind "beforeDestroy" , @removeItem

  resetBindings: =>
    Movimiento.unbind "beforeDestroy" , @removeItem
    Producto.unbind "current_set" , @addMovimiento


  addMovimiento: =>
    item = new Movimientos(producto: Producto.current)
    @movimientos.push item
    @movimientos_list.append item.el
    @itemToControllerMap[item.movimiento.id] = item

  removeItem: (item) =>
    item = @itemToControllerMap[item.id]
    index = @movimientos.indexOf(item)
    @movimientos.splice(index,1)
    @itemToControllerMap[item.id] = null

  customValidation: =>
    @validationErrors.push "Ingrese al menos un producto" if Movimiento.count() == 0
    item.checkItem() for item in @movimientos
    
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

  customReset: =>
    @log @movimientos
    for items in @movimientos
      items.reset()
    @documento.destroy()
    @resetBindings()
  

module.exports = Salidas