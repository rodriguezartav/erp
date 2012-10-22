require('lib/setup')
Spine = require('spine')
Productos = require("controllers/productos")
Documento = require("models/documento")
Producto = require("models/producto")
Movimiento = require("models/movimiento")
SmartProductos = require("controllers/smartProductos/smartProductos")
SmartItemEntrada = require("controllers/smartProductos/smartItemEntrada")


    

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
    ".src_smartProductos" : "src_smartProductos"

  events:
    "click .cancel"       :  "reset"
    "click .save"         :  "send"

  constructor: ->
    super
    Producto.reset_current()
    Movimiento.destroyAll()
    @documento = Documento.create {Tipo_de_Documento: "EN"}
    @html require("views/apps/auxiliares/entradas/layout")(@constructor)
    @smartProductos = new SmartProductos( el: @src_smartProductos , smartItem: SmartItemEntrada , referencia: "a")

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
      object.Observacion = ""
    
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
    Spine.socketManager.pushToFeed("Hice la entrada #{@documento.Referencia}")
    @reset()

  customReset: =>
    for item in Movimiento.all()
      item.destroy()
    @smartProductos.reset()
    @documento.destroy()
    @navigate "/apps"
    
  

module.exports = Entradas