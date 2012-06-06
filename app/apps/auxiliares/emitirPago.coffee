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
 
  constructor: ->
    super
    @setVariables()
    @preset()
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
    item.checkItem() for item in @items

  beforeSend: (object) =>
    for item in PagoItem.all()
      if item.Monto == 0
        item.destroy()
      else
        item.Recibo = object.Recibo
        item.Cliente = object.Cliente
        item.FormaPago = object.FormaPago
        item.Fecha = object.Fecha.to_salesforce_date()
        item.Referencia = object.Referencia
        item.setTipo()
        item.save()

  send: (e) =>
    @refreshElements()
    @updateFromView(@pago,@inputs_to_validate)
    
    data =
      class: PagoItem
      restData: PagoItem.all()

    Spine.trigger "show_lightbox" , "insert" , data , @after_send


  after_send: =>
    @minor_reset()

  reset: ->
    @minor_reset()
    @release()
    @navigate "/apps"

  minor_reset: () ->
    for item in @items
      item?.release()
    @resetBindings()
    Documento.destroyAll()
    Cliente.reset()
    @pago.destroy()
    @setVariables()
    @preset()
    @render()

    
module.exports = EmitirPago