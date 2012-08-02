Spine = require('spine')
Cliente = require("models/cliente")
Clientes = require("controllers/clientes")
Documento = require("models/documento")
Pago = require("models/transitory/pago")
PagoItem = require("models/transitory/pagoItem")

class Items extends Spine.Controller  
  @extend Spine.Controller.ViewDelegation
  tag: "tr"

  elements:
    ".validatable" : "inputs_to_validate"

  events:
    "click .incluir" : "add_saldo"
    "click .excluir" : "remove_saldo"
    "change input" : "checkItem"

  constructor: ->
    super
    @render()
    
  render: =>
    @html require("views/apps/print/estadoCuenta/item")(@documento)

  add_saldo: (e) =>
    @pagoItem.Monto = @pagoItem.Saldo
    @pagoItem.save()
    @render()
    
  remove_saldo: (e) =>
    @pagoItem.Monto = 0
    @pagoItem.save()
    @render()

  checkItem: (e) =>
    @updateFromView(@pagoItem,@inputs_to_validate)







class EstadoCuenta extends Spine.Controller
  @extend Spine.Controller.ViewDelegation
  
  className: "row-fluid"
  
  @departamento = "Credito y Cobro"
  @label = "Estado de Cuenta"
  @icon = "icon-inbox"

  elements:
    ".src_cliente"       :  "src_cliente"
    ".js_create_pago"    :  "btn_create_pago"
    ".saldos_list"       : "saldos_list"
    ".lbl_total"         : "lbl_total"
    ".validatable"       : "inputs_to_validate"
    ".info_popover"      : "info_popover"
    ".clienteName"       : "clienteName"
    ".clienteId"         : "clienteId"
    ".saldo"             : "saldo"
    
  events:
    "click .print" : "print"
  
  setVariables: ->
    @items = []

  setBindings: ->
    Documento.bind 'query_success' , @onDocumentoLoaded
    Cliente.bind 'current_set' , @onClienteSet
  
  resetBindings: ->
    Documento.unbind 'query_success' , @onDocumentoLoaded
    Cliente.unbind 'current_set' , @onClienteSet

  preset: ->
    Cliente.reset()
    Documento.destroyAll()
 
  constructor: ->
    super
    @preset()
    @setVariables()
    @render()
    @setBindings()
   
  render: =>
    @html require("views/apps/print/estadoCuenta/layout")(EstadoCuenta)
    @clientes = new Clientes(el: @src_cliente)

  onClienteSet: (cliente) =>
    @saldos_list.empty()
    Documento.destroyAll()
    Documento.query({ saldo: true , cliente: cliente  , autorizado: true })
    @clienteName.html cliente.Name
    @clienteId.html cliente.id

  onDocumentoLoaded: =>
    documentos = Documento.all()
    documentos.sort (a,b) ->
      return -1 if a.Tipo_de_Documento != "FA"
      return (a.Plazo - a.PlazoActual) - (b.Plazo - b.PlazoActual)
    
    saldo = 0 
    for documento in documentos
      saldo+= documento.Saldo
      ri = new Items(documento: documento)
      @items.push ri
      @saldos_list.append ri.el
    @saldo.html saldo.toMoney()

  print: ->
    window.print()

  reset: ->
    @resetBindings()
    @release()
    @navigate "/apps"


    
module.exports = EstadoCuenta