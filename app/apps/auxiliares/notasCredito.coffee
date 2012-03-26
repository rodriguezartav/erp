require('lib/setup')
Spine = require('spine')
Documento = require("models/documento")
Clientes = require("controllers/clientes")
Cliente = require("models/cliente")


class NotasCredito extends Spine.Controller
  @extend Spine.Controller.ViewDelegation

  @departamento = "Credito y Cobro" 
  @label = "Notas de Credito" 
  
  className: "row"

  elements:
    ".error" : "error"
    ".validatable" : "inputs_to_validate"
    ".src_cliente" : "src_cliente"

  events:
    "click .cancel" : "reset"
    "click .save" : "send"

  constructor: ->
    super
    @error.hide()
    Cliente.reset_current()

    @html require("views/apps/auxiliares/notasCredito/layout")(@documento)
    @clientes = new Clientes(el: @src_cliente)

  #####
  # ACTIONS
  #####

  customValidation: =>
    @validationErrors.push "Ingrese el Nombre del Cliente" if Cliente.current == null
    
  beforeSend: (object) ->
    object.Impuesto= 0
    object.Descuento= 0
    object.SubTotal = object.Total
    
  send: (e) =>
    @documento = Documento.create {Tipo_de_Documento: "NC"} if !@documento
    @updateFromView(@documento,@inputs_to_validate)
    return alert @validationErrors.join(" , ") if @validationErrors.length > 0
    
    @documento.Cliente = Cliente.current.id
    @documento.save()
    Spine.trigger "show_lightbox" , "sendDocumento" , @documento , @after_send
    
  after_send: =>
    @reset()
    
  reset: =>
    @inputs_to_validate.val ""
    Cliente.reset_current()
    @documento.destroy() if @documento
    @navigate "/apps"
    

module.exports = NotasCredito