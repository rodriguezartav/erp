Spine = require('spine')
Cliente = require("models/cliente")
Clientes = require("controllers/clientes")
Saldo = require("models/socketModels/saldo")
Pago = require("models/transitory/pago")
PagoItem = require("models/transitory/pagoItem")

class Items extends Spine.Controller  
  @extend Spine.Controller.ViewDelegation
  tag: "tr"
  className: "pago"

  elements:
    ".validatable" : "inputs_to_validate"

  events:
    "click .incluir" : "add_saldo"
    "click .excluir" : "remove_saldo"
    "change input" : "checkItem"

  constructor: ->
    super
    @pagoItem = PagoItem.createFromDocumento(@documento) if !@pagoItem
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
  
  @departamento = "Credito y Cobro"
  @label = "Ingresar Recibo"
  @icon = "icon-inbox"

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
    
  events:
    "click .cancel" : "onRemove"
    "click .save" : "send"
    "click .btn_forma_pago" : "onBtnFormaPagoClick"
    "click .btn_banco>li>a" : "onBtnBancoClick"

  setVariables: ->
    @items = []
    @formaPago = null
    @banco = ""
    @pagoItems = PagoItem.itemsInPago(@pago) if @pago
    @pago = Pago.create() if !@pago

  setBindings: =>
    PagoItem.bind "create update" , @updateTotal
    @clientes.bind "credito_data_changed"    , @onClienteSet
  
  resetBindings: =>
    PagoItem.unbind "create update" , @updateTotal
    @clientes.unbind "credito_data_changed"    , @onClienteSet
 
  constructor: ->
    super
    @setVariables()
    @render()
    @setBindings()

  render: ->
    @html require("views/apps/cuentasPorCobrar/singlePago/layout")(SinglePago)
    @refreshView(@pago,@inputs_to_validate)
    @clientes = new Clientes(el: @src_cliente , cliente: @pago.Cliente )
    @loadSaldos() if @pago.Cliente
    @renderConsecutivo() if !@pago.Recibo
    @renderPicker()

  renderConsecutivo: =>
    @pago.Recibo = parseInt Math.random() * 10000 # localStorage[SinglePago.label + "-Recibo"] || 0
    @pago.save()
    @txtRecibo.val (@pago.Recibo + 1)

  renderPicker: =>
    picker = @el.find('.txtFecha')
    pickers =  picker.datepicker({autoclose: true})
    picker.datepicker('setValue', new Date() )
    pickers.on("change",@onDateChange)

  onClienteSet: (cliente) =>
    @pago.Cliente = cliente.id
    @pago.save()
    @loadSaldos()

  loadSaldos: =>
    saldos = Saldo.findAllByAttribute "Cliente" , @pago.Cliente
    for saldo in saldos
      if saldo.Saldo == 0
        saldo.destroy() 
      else
        savedItem = PagoItem.saldoExists(saldo)
        ri = new Items
          pagoItem: savedItem
          documento:  saldo
        @items.push ri
        @saldos_list.append ri.el

  onDateChange: (e) =>
    target = $(e.target)
    @pago.Fecha = target.val()
    @pago.save()
    return false;

  updateTotal: =>
    total =0
    for item in PagoItem.all()
      total+= item.Monto
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
     

  send: (e) =>
    @txtReferencia.val "N/D" if @formaPago == "Efectivo" or @formaPago == "Nota Credito"
    @pago.Fecha = @txtFechaInput.val() if !@pago.Fecha
    @updateFromView(@pago,@inputs_to_validate)
    
    selectedPagoItems = []
    
    for item in @pagoItems
      item.Recibo = @pago.Recibo
      item.Cliente = @pago.Cliente
      item.FormaPago = @formaPago
      item.Fecha = @pago.Fecha
      item.Referencia = @pago.Referencia
      item.setTipo()
      selectedPagoItems.push item if item.Monto and parseInt(item.Monto) != 0

    data =
      class: PagoItem
      restRoute: "Pago"
      restMethod: "POST"
      restData: 
        pagos: PagoItem.salesforceFormat( selectedPagoItems , false) 

    Spine.trigger "show_lightbox" , "rest" , data , @after_send

  after_send: =>
    localStorage[IngresarRecibo.label + "-Recibo"] = @pago.Recibo
    cliente = Cliente.find @pago.Cliente
    Spine.socketManager.pushToFeed("#{cliente.Name} hizo un pago")
    @minor_reset()

  onRemove: =>
    @resetBindings()
    PagoItem.deleteItemsInPago(@pago)
    @pago.destroy()
    @onCancel?()
    @reset()

  reset: ->
    @minor_reset()
    @resetBindings()
    @release()

  minor_reset: () ->
    for item in @items
      item?.release()
    @clientes.reset()
    @setVariables()
    @render()

    
module.exports = SinglePago