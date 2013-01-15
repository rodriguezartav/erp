Spine = require('spine')
Cliente = require("models/cliente")
Clientes = require("controllers/clientes")
Documento = require("models/socketModels/saldo")
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
    @pagoItem = PagoItem.createFromDocumento( @documento , @pago )
    @render()

  render: =>
    @html require("views/apps/cuentasPorCobrar/singlePago/item")(@pagoItem)

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

class SinglePago extends Spine.Controller
  @extend Spine.Controller.ViewDelegation
  
  className: "row-fluid"

  elements:
    ".src_cliente"       :  "src_cliente"
    ".js_create_pago"    :  "btn_create_pago"
    ".saldos_list"       : "saldos_list"
    ".lbl_total"         : "lbl_total"
    ".validatable"       : "inputs_to_validate"
    ".info_popover"      : "info_popover"
    ".btn_forma_pago"    : "btn_forma_pago"
    ".selectFormaPago"   : "selectFormaPago"
    ".txtReferencia" : "txtReferencia"
    ".txtRecibo" : "txtRecibo"
    ".txtFecha>input" : "txtFechaInput"
    ".txt_diferencia" : "txtDiferencia"
    ".lbl_diferencia" : "lblDiferencia"
    
  events:
    "click .cancel" : "onCancelar"
    "click .save" : "send"
    "click .btn_forma_pago" : "onBtnFormaPagoClick"
    "click .btn_banco>li>a" : "onBtnBancoClick"
    "click .btn_documentos_refresh" : "onDocumentosRefresh"
    "change .txt_diferencia" : "onTxtDifereciaChange"

  setVariables: ->
    Cliente.reset()
    @items = []
    @formaPago = null
    @banco = ""
    @documentos= []

  setBindings: =>
    PagoItem.bind "create" , @updateTotal
    PagoItem.bind "update" , @updateTotal
    Cliente.bind 'current_set' , @onClienteSet

  resetBindings: =>
    PagoItem.unbind "create" , @updateTotal
    PagoItem.unbind "update" , @updateTotal
    Cliente.unbind 'current_set' , @onClienteSet

  constructor: ->
    super
    recibo = parseInt localStorage["SinglePago" + "-Recibo"] || 0
    @pago = Pago.create( UserStamp: Spine.session.getConsecutivoRecibo() , Recibo: recibo + 1)
    @setVariables()
    @render()
    @setBindings()

  render: ->
    @html require("views/apps/cuentasPorCobrar/singlePago/layout")(SinglePago)
    @refreshView(@pago,@inputs_to_validate)
    @clientes = new Clientes(el: @src_cliente)
    picker = @el.find('.txtFecha')
    pickers =  picker.datepicker({autoclose: true})
    picker.datepicker('setValue', new Date() )
    pickers.on("change",@onDateChange)

  onClienteSet: (cliente) =>
    @pago.Cliente = Cliente.current.id
    @pago.save()
    @onDocumentoLoaded()

  onDocumentosRefresh: =>
    Documento.ajax().query( { saldo: true , clienteId: @pago.Cliente , autorizado: true  } , afterSuccess: @onDocumentoLoaded , avoidQueryTimeBased: true )    

  onDocumentoLoaded: =>
    PagoItem.deleteItemsInPago(@pago)
    @documentos = Documento.findAllByAttribute "Cliente" , @pago.Cliente
    
    @documentos = @documentos.sort (a,b) =>
      return parseInt(a.Consecutivo) - parseInt(b.Consecutivo)
    
    @saldos_list.html ""
    for documento in @documentos
      if documento.Saldo != 0
        ri = new Items(documento: documento , pago: @pago )
        @items.push ri
        @saldos_list.append ri.el

  onDateChange: (e) =>
    target = $(e.target)
    @pago.Fecha = target.val()
    @pago.save()
    return false;

  updateTotal: =>
    total =0
    if !@pago
      console.log "pago not found"
      return false
    for item in PagoItem.itemsInPago(@pago)
      total+= item.Monto
    @pago.Monto = total;
    @pago.save()
    @lbl_total.html total.toMoney()

  onBtnFormaPagoClick: (e) =>
    target = $(e.target)
    @btn_forma_pago.removeClass "btn-primary"
    target.addClass "btn-primary"
    @formaPago = target.attr "data-forma-pago"

  onBtnBancoClick: (e) =>
    target = $(e.target)
    @txtReferencia.val target.html() + " "
    @txtReferencia.focus()

  onTxtDifereciaChange: (e) =>
    target = $(e.target)
    value = parseFloat(target.val())
    @lblDiferencia.html (value - @pago.Monto).toMoney()
    target.val value.toMoney()

  customValidation: =>
    @validationErrors.push "Ingrese el Nombre del Cliente" if @pago.Cliente == null
    @validationErrors.push "El pago debe tener al menos 1 pago" if PagoItem.count() == 0
    @validationErrors.push "Escoja una forma de pago" if @formaPago == null
    hasFactura = false
    total = 0
    for item in @items
      hasFactura = true if item.pagoItem.Monto and parseInt(item.pagoItem.Monto) != 0 and item.documento.Tipo_de_Documento == 'FA'
      hasFactura = true if item.pagoItem.Monto and parseInt(item.pagoItem.Monto) != 0 and item.documento.Tipo_de_Documento == 'ND'
      total += item.pagoItem.Monto if item.pagoItem.Monto and parseInt(item.pagoItem.Monto) != 0
      item.checkItem()
    @validationErrors.push "El pago debe tener al menos una factura o nota de debito" if !hasFactura
    @validationErrors.push "El pago debe ser mayor o igual a 0" if total < 0
    @pago.Monto = total;
    @pago.Fecha = @txtFechaInput.val() if !@pago.Fecha
    @pago.FormaPago = @formaPago
    @pago.save()

  send: (e) =>
    target = $(e.target)
    send = if target.data("send") then true else false
    @txtReferencia.val "N/D" if @formaPago == "Efectivo" or @formaPago == "Nota Credito"
    @updateFromView(@pago,@inputs_to_validate)
    @resetBindings()
    @pagoItems = PagoItem.itemsInPago(@pago)
    for item in @pagoItems
      item.Recibo = @pago.Recibo
      item.Cliente = @pago.Cliente
      item.FormaPago = @pago.FormaPago
      item.Fecha = @pago.Fecha
      item.Referencia = @pago.Referencia
      item.setTipo()
      item.UsedInPago = if !item.Monto or item.Monto == 0 then false else true
      item.save()

    if send
      pagoItems = []
      for pagoItem in @pagoItems
        pagoItems.push pagoItem if pagoItem.UsedInPago
      console.log pagoItems
      data =
        class: PagoItem
        restRoute: "Pago"
        restMethod: "POST"
        restData: 
          pagos: PagoItem.salesforceFormat( pagoItems , false) 
      Spine.trigger "show_lightbox" , "rest" , data , @after_send_send
    else
      @after_send_save()

  after_send_send: =>
    localStorage["SinglePago" + "-Recibo"] = @pago.Recibo
    @reset(true)
    @onSuccess?( true )

  after_send_save: =>
    localStorage["SinglePago" + "-Recibo"] = @pago.Recibo
    @reset()
    @onSuccess?()

  onCancelar: =>
    @reset(true)
    @onCancel?()

  reset: (deletePago = false) ->
    @resetBindings()
    for item in @items
      item?.release()
    if deletePago
      @pago.destroy()
      if @pagoItems
        item.destroy() for item in @pagoItems
    @pago = null
    @pagoItem = null
    @destroyUnusedItems()
    @setVariables()
    @release()


  destroyUnusedItems: =>
    for item in PagoItem.all()
      pagoId = item.Pago
      item.destroy() if item.Monto ==0
        

    
module.exports = SinglePago