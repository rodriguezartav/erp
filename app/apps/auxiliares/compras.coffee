require('lib/setup')
Spine = require('spine')
Movimientos = require("controllers/movimientos")
Producto = require("models/producto")
Movimiento = require("models/movimiento")
Cuenta = require("models/cuenta")

class Compras extends Spine.Controller
  @extend Spine.Controller.ViewDelegation
  
  className: "row"

  @departamento = "Inventarios"
  @label = "Compra de Mercaderia"

  elements:
    ".src_movimientos" : "src_movimientos"
    ".error" : "error"
    ".validatable" : "inputs_to_validate"

  events:
    "click .cancel" : "reset"
    "click .save" : "send"

  constructor: ->
    super
    @error.hide()
    @render()
    
  render: =>  
    @html require("views/apps/auxiliares/compras/layout")(@documento)
    @movimientos = new Movimientos(el: @src_movimientos , layout: "compras")
    
  customValidation: =>
    @validationErrors.push "Ingrese al menos un producto" if Movimiento.count() == 0
    
  beforeSend: (object) ->
    for movimiento in Movimiento.all()
      movimiento.Tipo             = object.Tipo_de_Documento
      movimiento.Nombre_Contado   = object.Nombre_Contado
      movimiento.Precio           = 0
      movimiento.Impuesto         = 0
      movimiento.Descuento        = 0
      movimiento.Observacion      = object.Observacion
      movimiento.Referencia       = object.Referencia
      movimiento.save()
   
  send: (e) =>
    @documento = Documento.create {Tipo_de_Documento: "CO"} if !@documento
    @updateFromView(@documento,@inputs_to_validate)
    Spine.trigger "show_lightbox" , "sendMovimientos" , Movimiento.all() , @after_send   

  after_send: =>
    @reset()

  reset: ->
    @movimientos?.cancel()
    Movimiento.destroyAll()
    @documento.destroy() if @documento   
    @inputs_to_validate.val ""
    @navigate "/apps"

module.exports = Compras