Spine = require('spine')
Saldo = require("models/sobjects/saldo")
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
    "change input" : "on_monto_change"

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

  on_monto_change: (e) =>
    @updateFromView(@pagoItem,@inputs_to_validate)

class EmitirPago extends Spine.Controller
  @extend Spine.Controller.ViewDelegation
  
  className: "row-fluid"
  
  @departamento = "Credito y Cobro"
  @label = "Crear Pagos"

  elements:
    ".src_cliente"       :  "src_cliente"
    ".js_create_pago"    :  "btn_create_pago"
    ".saldos_list"       : "saldos_list"
    ".lbl_total"         : "lbl_total"
    ".validatable"       : "inputs_to_validate"
    
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
    new Clientes(el: @src_cliente)

  onClienteSet: (cliente) =>
    @reset() if @pago.Cliente
    Documento.destroyAll()
    Documento.query({ saldo: true , cliente: cliente , estado: "Impreso" })
    @pago.Cliente = Cliente.current.id
    

  onDocumentoLoaded: =>
    for documento in Documento.all()
      ri = new Items(documento: documento)
      @items.push ri
      @saldos_list.append ri.el

  updateTotal: =>
    total =0
    for item in PagoItem.all()
      total+= item.Monto
    @lbl_total.html total.toMoney()

  beforeSend: (object) =>
    for item in PagoItem.all()
      if item.Monto == 0
        item.destroy()
      else
        item.Recibo = object.Recibo
        item.Cliente = object.Cliente
        item.Tipo = if item.Monto == item.Saldo then "PA" else "AB"
        item.FormaPago = object.FormaPago
        item.Fecha = object.Fecha.to_salesforce_date()
        item.Referencia = object.Referencia
        item.save()
        @log item

  send: (e) =>
    @refreshElements()
    @updateFromView(@pago,@inputs_to_validate)
    @log PagoItem.all()
    Spine.trigger "show_lightbox" , "sendPagos" , PagoItem.all() , @after_send   

  after_send: =>
    @reset()

  reset: () ->
    for item in @items
      item.release()
    Cliente.unbind 'current_set' , @on_cliente_set
    for item in PagoItem.all()
      item.destroy()
    @pago.destroy()
    @navigate "/apps"

module.exports = EmitirPago