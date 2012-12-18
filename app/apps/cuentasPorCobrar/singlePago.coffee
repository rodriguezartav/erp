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
    @pagoItem = PagoItem.createFromDocumento(@documento,@pago)
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
    "change .txt_diferencia" : "onTxtDifereciaChange"

  setVariables: ->
    Cliente.reset()
    @items = []
    @formaPago = null
    @banco = ""
    @documentos= []

  setBindings: ->
    PagoItem.bind "create update" , @updateTotal
    Cliente.bind 'current_set' , @onClienteSet
  
  resetBindings: ->
    PagoItem.unbind "create update" , @updateTotal
    Cliente.unbind 'current_set' , @onClienteSet

  constructor: ->
    super
    @setVariables()
    @pago = Pago.create( UserStamp: Spine.session.getConsecutivoRecibo() , Recibo: recibo + 1)
    @render()
    @setBindings()

  render: ->
    @html require("views/apps/cuentasPorCobrar/singlePago/layout")(SinglePago)
    recibo = parseInt localStorage["SinglePago" + "-Recibo"] || 0
    @refreshView(@pago,@inputs_to_validate)
    @clientes = new Clientes(el: @src_cliente)
    
    picker = @el.find('.txtFecha')
    pickers =  picker.datepicker({autoclose: true})
    picker.datepicker('setValue', new Date() )
    pickers.on("change",@onDateChange)

  onClienteSet: (cliente) =>
    #Documento.destroyAll()
    #Documento.ajax().query( { saldo: true , cliente: cliente  , autorizado: true } , afterSuccess: @onDocumentoLoaded )    
    @pago.Cliente = Cliente.current.id
    @pago.save()
    @onDocumentoLoaded()

  onDocumentoLoaded: =>
    @documentos = Documento.findAllByAttribute "Cliente" , @pago.Cliente
    for documento in @documentos
      ri = new Items(documento: documento , pago: @pago )
      @items.push ri
      @saldos_list.append ri.el
    #$('.info_popover').popover()

  onDateChange: (e) =>
    target = $(e.target)
    @pago.Fecha = target.val()
    @pago.save()
    return false;

  updateTotal: =>
    total =0
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
    @txtReferencia.val "N/D" if @formaPago == "Efectivo" or @formaPago == "Nota Credito"
    @updateFromView(@pago,@inputs_to_validate)
    @resetBindings()
    for item in PagoItem.itemsInPago(@pago)
      item.Recibo = @pago.Recibo
      item.Cliente = @pago.Cliente
      item.FormaPago = @pago.FormaPago
      item.Fecha = @pago.Fecha
      item.Referencia = @pago.Referencia
      item.setTipo()
      item.UsedInPago = if item.Monto == 0 then false else true
      item.save()
    

    #data =
    #  class: PagoItem
    #  restRoute: "Pago"
    #  restMethod: "POST"
    #  restData: 
    #    pagos: PagoItem.salesforceFormat( pagoItems , false) 

    #Spine.trigger "show_lightbox" , "rest" , data , @after_send

  #after_send: =>
    localStorage["SinglePago" + "-Recibo"] = @pago.Recibo
    #cliente = Cliente.find @pago.Cliente
    #Spine.socketManager.pushToFeed("#{cliente.Name} hizo un pago")
    pagoId = @pago.id
    @reset()
    @onSuccess?( pagoId )

  onCancelar: =>
    @reset()
    @onCancel?()

  reset: ->
    @minor_reset()
    @resetBindings()
    @release()

  minor_reset: () ->
    for item in @items
      item?.release()
    @pago = null
    for item in PagoItem.all()
      item.destroy() if !item.UsedInPago 
    @setVariables()

    
module.exports = SinglePago