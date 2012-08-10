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
    Cliente.bind "current_set" , @onClienteSet
      
  
  onClienteSet: =>
    @documento.Cliente = Cliente.current.id
    @documento.save()

  customValidation: =>
    @validationErrors.push "Ingrese el Nombre del Cliente" if Cliente.current == null
    
  beforeSend: (documento) ->
    documento.Plazo = 30
    documento.Autorizado = false;
    
  send: (e) =>
    @updateFromView(@documento,@inputs_to_validate)    
    
    data =
      class: Documento
      restData: [@documento]

    Spine.trigger "show_lightbox" , "insert" , data , @after_send

  after_send: =>
    Spine.socketManager.pushToFeed("Hice un Nota de Credito para #{Cliente.current.Name}")
    
    @reset(false)
    
  customReset: =>
    Cliente.reset_current()
    Cliente.unbind "current_set" , @onClienteSet
    @clientes.reset()
    @documento.destroy() if @documento
    @navigate "/apps"
    
    

module.exports = NotasCredito