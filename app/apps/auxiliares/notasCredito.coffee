require('lib/setup')
Spine = require('spine')
Documento = require("models/documento")
Clientes = require("controllers/clientes")
Cliente = require("models/cliente")

class NotasCredito extends Spine.Controller
  @extend Spine.Controller.ViewDelegation

  @departamento = "Credito y Cobro" 
  @label = "Notas de Credito" 
  @icon = "icon-envelope"

  className: "row-fluid"

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
    @documento = Documento.create {Tipo_de_Documento: "NC"}
    @html require("views/apps/auxiliares/notasCredito/layout")(NotasCredito)
    @clientes = new Clientes(el: @src_cliente)
    Cliente.bind "current_set" , =>
      @documento.Cliente = Cliente.current.id
      @documento.save()

  customValidation: =>
    @validationErrors.push "Ingrese el Nombre del Cliente" if Cliente.current == null
    
  beforeSend: (documento) ->
    documento.Impuesto= 0
    documento.Descuento= 0
    documento.SubTotal = documento.Total
    
  send: (e) =>
    @updateFromView(@documento,@inputs_to_validate)    
    Spine.trigger "show_lightbox" , "sendDocumento" , @documento , @after_send
    
  after_send: =>
    @reset(false)
    
  customReset: =>
    Cliente.reset_current()
    @documento.destroy() if @documento
    

module.exports = NotasCredito