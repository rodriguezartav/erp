require('lib/setup')
Spine = require('spine')
Documento = require("models/documento")
Clientes = require("controllers/clientes")
Cliente = require("models/cliente")


class NotasDebito extends Spine.Controller
  @extend Spine.Controller.ViewDelegation

  @departamento = "Credito y Cobro"
  @label = "Notas de Debito"
  @icon = "icon-download-alt"
  
  
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
    @documento = Documento.create {Tipo_de_Documento: "ND"}
    @html require("views/apps/auxiliares/notasDebito/layout")(@constructor)
    @clientes = new Clientes(el: @src_cliente)
    Cliente.bind "current_set" , =>
      @documento.Cliente = Cliente.current.id
      @documento.save()

  customValidation: =>
    @validationErrors.push "Ingrese el Nombre del Cliente" if Cliente.current == null
    
  beforeSend: (object) ->
    object.Plazo = 30
    
  send: (e) =>
    @updateFromView(@documento,@inputs_to_validate)
    data =
      class: Documento
      restData: [@documento]

    Spine.trigger "show_lightbox" , "insert" , data , @after_send   
    
#    Spine.trigger "show_lightbox" , "insert" , @documento , @after_send
    
  after_send: =>
    @reset(false)
    
  customReset: =>
    Cliente.reset_current()
    @documento.destroy() if @documento
    

module.exports = NotasDebito