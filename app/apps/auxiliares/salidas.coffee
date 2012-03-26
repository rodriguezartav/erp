require('lib/setup')
Spine = require('spine')
Movimientos = require("controllers/movimientos")
Documento = require("models/documento")
Producto = require("models/producto")
Movimiento = require("models/movimiento")

class Salidas extends Spine.Controller
  @extend Spine.Controller.ViewDelegation

  @departamento = "Inventarios"
  @label = "Salida de Mercaderia"

  className: "row"

  elements:
    ".error" : "error"
    ".validatable" : "inputs_to_validate"
    ".src_movimientos" : "src_movimientos"

  events:
    "click .cancel" : "reset"
    "click .save" : "send"

  constructor: ->
    super
    @error.hide()
    @render()
    
  render: =>  
    @html require("views/apps/auxiliares/salidas/layout")(@documento)
    @movimientos = new Movimientos(el: @src_movimientos , layout: "movimientos")

  #####
  # ACTIONS
  #####
  customValidation: =>
    @validationErrors.push "Ingrese al menos un producto" if Movimiento.count() == 0
    
  beforeSend: (object) ->
    for movimiento in Movimiento.all()
      movimiento.Tipo             = object.Tipo_de_Documento
      movimiento.Precio           = 0
      movimiento.Impuesto         = 0
      movimiento.Descuento        = 0
      movimiento.Observacion      = object.Observacion
      movimiento.Referencia       = object.Referencia
      movimiento.save()
    
  send: (e) =>
    @documento = Documento.create {Tipo_de_Documento: "SA"} if !@documento
    @updateFromView(@documento,@inputs_to_validate)
    Spine.trigger "show_lightbox" , "sendMovimientos" , Movimiento.all() , @after_send   


  after_send: =>
    @reset()

  reset: ->
    @movimientos?.reset()
    Movimiento.destroyAll()
    @documento.destroy() if @documento   
    @inputs_to_validate.val ""
    @navigate "/apps"

module.exports = Salidas