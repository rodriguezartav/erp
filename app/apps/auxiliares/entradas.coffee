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
    @html require("views/apps/auxiliares/entradas/item")(@movimiento)
  
  checkItem: (e) =>
    @updateFromView(@movimiento,@inputs_to_validate)
    
  reset: ->
    @movimiento.destroy()
    @release()
    

class Entradas extends Spine.Controller
  @extend Spine.Controller.ViewDelegation
  className: "row-fluid"

  @departamento = "Inventarios"
  @label = "Entradas"
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
    Movimiento.destroyAll()
    @movimientos = []
    @itemToControllerMap = {}

    @documento = Documento.create {Tipo_de_Documento: "EN"}
    @html require("views/apps/auxiliares/entradas/layout")(@constructor)
    @error.hide()
    @setBindings()

  setBindings: =>
    Producto.bind "current_set" , @addMovimiento
    Movimiento.bind "beforeDestroy" , @removeMovimiento

  resetBindings: =>
    Movimiento.unbind "beforeDestroy" , @removeMovimiento
    Producto.unbind "current_set" , @addMovimiento
    
    
  addMovimiento: =>
    movimiento =  Movimiento.findAllByAttribute("Producto" , Producto.current.id)
    if(movimiento.length == 0)
      item = new Movimientos(producto: Producto.current)
      @movimientos.push item
      @itemToControllerMap[item.movimiento.id] = item
      @movimientos_list.append item.el


  removeMovimiento: (item) =>
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
      object.Observacion = ""
    
  send: (e) =>
    @updateFromView(@documento,@inputs_to_validate)
    
    data =
      class: Movimiento
      restData: Movimiento.all()

    Spine.trigger "show_lightbox" , "insert" , data , @after_send
    

  after_send: =>
    Spine.socketManager.pushToFeed( "Hice la entrada #{@documento.Referencia}")
    @reset()

  customReset: =>
    for items in @movimientos
      items?.reset()
    @documento.destroy()
    @resetBindings()
    @navigate "/apps"
    
  

module.exports = Entradas