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
    @pagoItem = PagoItem.createFromDocumento(@documento)
    @render()
    
  render: =>
    @html require("views/apps/auxiliares/emitirPago/item")(@pagoItem)

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

class EmitirPago extends Spine.Controller
  @extend Spine.Controller.ViewDelegation
  
  className: "row-fluid"
  
  @departamento = "Credito y Cobro"
  @label = "Crear Pagos"
  @icon = "icon-inbox"

  elements:
    ".src_cliente"       :  "src_cliente"
    ".js_create_pago"    :  "btn_create_pago"
    ".saldos_list"       : "saldos_list"
    ".lbl_total"         : "lbl_total"
    ".validatable"       : "inputs_to_validate"
    ".info_popover"      : "info_popover"
    
  events:
    "click .cancel" : "reset"
    "click .save" : "send"

  setVariables: ->
    @items = []
    @pago = Pago.create { Fecha: new Date() }

  setBindings: ->
    Documento.bind 'query_success' , @onDocumentoLoaded
    PagoItem.bind "create update" , @updateTotal
    Cliente.bind 'current_set' , @onClienteSet
  
  resetBindings: ->
    Documento.unbind 'query_success' , @onDocumentoLoaded
    PagoItem.unbind "create update" , @updateTotal
    Cliente.unbind 'current_set' , @onClienteSet

  preset: ->
    Cliente.reset()
    PagoItem.destroyAll()
    Pago.destroyAll()
    Documento.destroyAll()
 
  constructor: ->
    super
    @preset()
    @setVariables()
    @render()
    @setBindings()
   
  render: ->
    @html require("views/apps/auxiliares/emitirPago/layout")(EmitirPago)
    @refreshView(@pago,@inputs_to_validate)    
    @clientes = new Clientes(el: @src_cliente)

  onClienteSet: (cliente) =>
    Documento.destroyAll()
    Documento.query({ saldo: true , cliente: cliente  , autorizado: true })
    @pago.Cliente = Cliente.current.id

  onDocumentoLoaded: =>
    for documento in Documento.all()
      ri = new Items(documento: documento)
      @items.push ri
      @saldos_list.append ri.el
    $('.info_popover').popover()

  updateTotal: =>
    total =0
    for item in PagoItem.all()
      total+= item.Monto
    @lbl_total.html total.toMoney()

  customValidation: =>
    @validationErrors.push "Ingrese el Nombre del Cliente" if @pago.Cliente == null
    @validationErrors.push "El pago debe tener al menos 1 pago" if PagoItem.count() == 0
    hasFactura = false
    total = 0
    for item in @items
      hasFactura = true if item.pagoItem.Monto and parseInt(item.pagoItem.Monto) != 0 and item.documento.Tipo_de_Documento == 'FA'
      total += item.pagoItem.Monto if item.pagoItem.Monto and parseInt(item.pagoItem.Monto) != 0
      item.checkItem()
    @validationErrors.push "El pago debe tener al menos una factura " if !hasFactura
    @validationErrors.push "El pago debe ser mayor o igual a 0" if total < 0
     

  send: (e) =>
    @updateFromView(@pago,@inputs_to_validate)
    
    pagoItems = []
    
    for item in PagoItem.all()
      item.Recibo = @pago.Recibo
      item.Cliente = @pago.Cliente
      item.FormaPago = @pago.FormaPago
      item.Fecha = @pago.Fecha.to_salesforce_date()
      item.Referencia = @pago.Referencia
      item.setTipo()
      pagoItems.push item if item.Monto and parseInt(item.Monto) != 0

    data =
      class: PagoItem
      restData: pagoItems

    Spine.trigger "show_lightbox" , "insert" , data , @after_send

  after_send: =>
    @minor_reset()

  reset: ->
    @minor_reset()
    @resetBindings()
    @release()
    @navigate "/apps"

  minor_reset: () ->
    for item in @items
      item?.release()
    @preset()  
    @setVariables()
    @render()

    
module.exports = EmitirPago