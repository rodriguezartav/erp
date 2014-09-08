require('lib/setup')
Spine = require('spine')
Producto = require("models/producto")
ProductoCosto = require("models/productoCosto")
Movimiento = require("models/movimiento")
Documento = require("models/documento")
Proveedores = require("controllers/proveedores")
Proveedor = require("models/proveedor")
SmartProductos = require("controllers/smartProductos/smartProductos")
SmartItemCompra = require("controllers/smartProductos/smartItemCompra")

class Compras extends Spine.Controller
  @extend Spine.Controller.ViewDelegation
  
  className: "row-fluid"

  @departamento = "Inventarios"
  @label = "Compras"
  @icon = "icon-shopping-cart"

  elements:
    ".src_smartProductos" : "src_smartProductos"
    ".validatable"     : "inputs_to_validate"
    ".src_proveedor" : "src_proveedor"

  events:
    "click .cancel" : "reset"
    "click .save" : "send"

  constructor: ->
    super
    ProductoCosto.destroyAll()
    ProductoCosto.query()

    @documento = Documento.create {Tipo_de_Documento: "CO"}    
    Movimiento.destroyAll()
    @html require("views/apps/auxiliares/compras/layout")(@constructor)
    @smartProductos = new SmartProductos( el: @src_smartProductos , smartItem: SmartItemCompra , referencia: "a")    
    @proveedores = new Proveedores(el: @src_proveedor)

  customValidation: =>
    @validationErrors.push "Ingrese al menos un producto" if Movimiento.count() == 0
    @validationErrors.push "Escoja el Proveedor" if Proveedor.current == null

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
      restRoute: "Movimiento"
      restMethod: "POST"
      restData: 
        movimientos: Movimiento.salesforceFormat( Movimiento.all() , false) 

    Spine.trigger "show_lightbox" , "rest" , data , @after_send

  after_send: =>
    proveedor = @src_proveedor.find("input")
    Spine.socketManager.pushToFeed( "Hice la entrada de mercaderia #{@documento.Referencia} de #{proveedor.val()}")
    @reset(false)

  customReset: =>
    Producto.bypassInventario = false
    @proveedores.reset()
    @smartProductos.reset()
    @documento.destroy()
    @navigate "/apps"
    
    
  
module.exports = Compras