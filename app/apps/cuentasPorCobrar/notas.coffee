require('lib/setup')
Spine = require('spine')
Documento = require("models/documento")
Clientes = require("controllers/clientes")
Cliente = require("models/cliente")

class Notas extends Spine.Controller
  @extend Spine.Controller.ViewDelegation

  @departamento = "Credito y Cobro" 
  @label = "Credito y Debito" 
  @icon = "icon-envelope"

  className: "row-fluid"

  elements:
    ".error" : "error"
    ".validatable" : "inputs_to_validate"
    ".src_cliente" : "src_cliente"
    ".subtotal" : "subtotal"
    ".descuento" : "descuento"
    ".impuesto" : "impuesto"
    ".total" : "total"
    ".lbl_total_format" : "lbl_total_format"

  events:
    "click .cancel" : "reset"
    "click .save" : "send"
    "change .totales" : "onTotalesChange"


  constructor: ->
    super
    @error.hide()
    Cliente.reset_current()
    @documento = Documento.create( Tipo_de_Documento: "NC" )
    @html require("views/apps/cuentasPorCobrar/notas/layout")(Notas)
    @clientes = new Clientes(el: @src_cliente)
    Cliente.bind "current_set" , @onClienteSet
    @renderToggle()

  renderToggle: =>
    @el.find('.nota_toggle').toggleButtons
      width: 250,
      label:
        enabled: "Credito"
        disabled: "Debito"
      onChange: ($el, status, e) =>
        selectedTipo = if status then "NC" else "ND"
        @documento.Tipo_de_Documento = selectedTipo
        @documento.save()
        return true

  onClienteSet: =>
    @documento.Cliente = Cliente.current.id
    @documento.save()

  onTotalesChange: =>
    sub = parseFloat(@subtotal.val()) || 0
    desc = parseFloat(@descuento.val()) || 0
    imp = parseFloat(@impuesto.val()) || 0
    @total.val sub - desc + imp
    @lbl_total_format.html (sub - desc + imp).toMoney()

  customValidation: =>
    @validationErrors.push "Ingrese el Nombre del Cliente" if Cliente.current == null
    @validationErrors.push "Subtotal no puede ser 0" if !@documento.SubTotal or  @documento.SubTotal == 0

  beforeSend: (documento) ->
    documento.Plazo = 30
    documento.Autorizado = false;
    
  send: (e) =>
    @updateFromView(@documento,@inputs_to_validate)    

    Spine.trigger "show_lightbox" , "insert" , @documento , @after_send

  after_send: =>
    Spine.socketManager.pushToFeed("Hice un Nota de Credito para #{Cliente.current.Name}")
    @reset(false)
    
  customReset: =>
    Cliente.reset_current()
    Cliente.unbind "current_set" , @onClienteSet
    @clientes.reset()
    @documento.destroy() if @documento
    @navigate "/apps"

module.exports = Notas