require('lib/setup')
Spine = require('spine')
Producto = require("models/producto")
ProductoCosto = require("models/productoCosto")
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
    "click .btn_remove" : "reset"
    "change input" : "checkItem"
    "click input" : "onItemClick"
    
  constructor: ->
    super 
    @movimiento = Movimiento.create_from_producto(@producto, @cantidad)
    @html require("views/apps/auxiliares/compras/item")(movimiento: @movimiento , productoCosto: @productoCosto)

  onItemClick: (e) =>
    target = $(e.target)
    target.select()

  checkItem: (e) =>
    @updateFromView(@movimiento,@inputs_to_validate)
    if e and e.target
      target = $(e.target)
      $(":input:eq(" + ($(":input").index(target) + 1) + ")").focus();
    
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
    ProductoCosto.destroyAll()
    Proveedor.query()
    ProductoCosto.query()
    
    @documento = Documento.create {Tipo_de_Documento: "CO"}   
 
    Movimiento.destroyAll()
    @movimientos = []
    @itemToControllerMap = {}

    @html require("views/apps/auxiliares/compras/layout")(@constructor)
    @proveedores = new Proveedores(el: @src_proveedor)
    @setBindings()

  setBindings: =>
    Producto.bind "current_set" , @addMovimiento
    Movimiento.bind "beforeDestroy" , @removeMovimiento
    
  resetBindings: =>
    Producto.unbind "current_set" , @addMovimiento
    Movimiento.unbind "beforeDestroy" , @removeMovimiento

  addMovimiento: (p,cantidad) =>
    if ProductoCosto.count() > 0
      movimiento =  Movimiento.findAllByAttribute("Producto" , Producto.current.id)
      productoCosto = ProductoCosto.find Producto.current.id
    
      if(movimiento.length == 0)
        item = new Movimientos(producto: Producto.current, cantidad: cantidad, productoCosto: productoCosto)
        @itemToControllerMap[item.movimiento.id] = item
        @movimientos.push item
        @movimientos_list.append item.el
    else
      Spine.trigger "show_lightbox" , "showWarning" , error: "Cargando Costos, espere hasta que el cargador de la barra superior a la derecha se detenga"

  removeMovimiento: (item) =>
    item = @itemToControllerMap[item.id]
    index = @movimientos.indexOf(item)
    @movimientos.splice(index,1)
    @itemToControllerMap[item.id] = null

  customValidation: =>
    @validationErrors.push "Ingrese al menos un producto" if Movimiento.count() == 0
    @validationErrors.push "Escoja el Proveedor" if Proveedor.current == null
    item.checkItem() for item in @movimientos

  beforeSend: (object) ->
    for movimiento in Movimiento.all()
      movimiento.Tipo             = object.Tipo_de_Documento
      movimiento.Nombre_Contado   = Proveedor.current.Name + ' ' + object.Referencia
      movimiento.Precio           = 0
      movimiento.Impuesto         = 0
      movimiento.Descuento        = 0
      movimiento.Observacion      = object.Observacion
      movimiento.Referencia       = object.Referencia
      movimiento.SubTotal         = 0
      movimiento.save()
      object.Observacion = " "
   
  send: (e) =>
    @updateFromView(@documento,@inputs_to_validate)
    
    data =
      class: Movimiento
      restData: Movimiento.all()

    Spine.trigger "show_lightbox" , "insert" , data , @after_send

  after_send: =>
    @reset(false)

  customReset: =>
    @proveedores.reset()
    @resetBindings()
    for items in @movimientos
      items?.reset()
    @documento.destroy()
    @navigate "/apps"
    
    
  
module.exports = Compras