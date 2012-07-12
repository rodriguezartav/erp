require('lib/setup')
Spine = require('spine')
Productos = require("controllers/productos")
Documento = require("models/documento")
Producto = require("models/producto")
Movimiento = require("models/movimiento")
Cliente = require("models/cliente")
Clientes = require("controllers/clientes")


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
    @html require("views/apps/auxiliares/reposiciones/item")(@movimiento)
    
  
  checkItem: (e) =>
    @updateFromView(@movimiento,@inputs_to_validate)
    
  customReset: ->
    @movimiento.destroy()
    @release()
    

class Reposiciones extends Spine.Controller
  @extend Spine.Controller.ViewDelegation

  @departamento = "Inventarios"
  @label = "Reposicion de Mercaderia"
  @icon = "icon-arrow-left"

  className: "row-fluid"

  elements:
    ".error"              :  "error"
    ".validatable"        :  "inputs_to_validate"
    ".movimientos_list"   :  "movimientos_list"
    ".src_cliente" : "src_cliente"
    

  events:
    "click .cancel"       :  "reset"
    "click .save"         :  "send"

  constructor: ->
    super
    Producto.reset_current()
    Movimiento.destroyAll()
    Cliente.reset_current()
    
    @movimientos = []
    @itemToControllerMap= []

    @documento = Documento.create {Tipo_de_Documento: "RE"}
    @html require("views/apps/auxiliares/reposiciones/layout")(@constructor)
    @clientes = new Clientes(el: @src_cliente)
    
    @error.hide()
    @setBindings()

  setBindings: =>
    Producto.bind "current_set" , @addMovimiento
    Movimiento.bind "beforeDestroy" , @removeItem
    Cliente.bind 'current_set' , @onClienteSet
    

  resetBindings: =>
    Movimiento.unbind "beforeDestroy" , @removeItem
    Producto.unbind "current_set" , @addMovimiento
    Cliente.unbind 'current_set' , @onClienteSet


  onClienteSet: (cliente) =>
    @documento.Cliente = Cliente.current.id

  addMovimiento: =>
    movimiento =  Movimiento.findAllByAttribute("Producto" , Producto.current.id)
    if(movimiento.length == 0)
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
    @validationErrors.push "Debe escoger un cliente" if Cliente.current == null
    item.checkItem() for item in @movimientos
    
  beforeSend: (object) ->
    for movimiento in Movimiento.all()
      movimiento.Tipo             = object.Tipo_de_Documento
      movimiento.Cliente          = object.Cliente
      movimiento.Precio           = 0
      movimiento.Impuesto         = 0
      movimiento.Descuento        = 0
      movimiento.SubTotal         = 0
      movimiento.Observacion      = object.Observacion
      movimiento.Referencia       = object.Referencia
      movimiento.save()
    
  send: (e) =>
    @updateFromView(@documento,@inputs_to_validate)
   
    data =
      class: Movimiento
      restData: Movimiento.all()

    Spine.trigger "show_lightbox" , "insert" , data , @after_send

  after_send: =>
    @reset()

  customReset: =>

    for items in @movimientos
      items?.reset()
    @documento.destroy()
    @resetBindings()
    @navigate "/apps"
    
  

module.exports = Reposiciones