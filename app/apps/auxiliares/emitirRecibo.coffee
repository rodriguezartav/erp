require('lib/setup')
Spine = require('spine')
Saldo = require("models/sobjects/saldo")
Cliente = require("models/cliente")
Clientes = require("controllers/clientes")
Producto = require("models/producto")
Documento = require("models/documento")
Recibo = require("models/recibo")

class EmitirRecibos extends Spine.Controller
  @extend Spine.Controller.ViewDelegation

  @departamento = "Tesoreria"
  @label = "Emitir Recibos"
  
  className: "row"

  elements:
    ".error"                      : "error"
    ".validatable"                : "inputs_to_validate"
    ".src_cliente"                : "src_cliente"
    ".item_loader"                : "item_loader"
    ".documentos_list"            : "documentos_list"
    ".txt_saldo_pendiente_monto"  : "txt_saldo_pendiente_monto"
    ".lbl_total" : "lbl_total"
    ".txt_codigo" : "txt_codigo"

  events:
    "click .cancel"  : "reset"
    "click .save"    : "send"
    "click .incluir" : "add_saldo"
    "click .excluir" : "remove_saldo"
    "change .txt_saldo_pendiente_monto" : "on_saldo_change"

  constructor: ->
    super
    @error.hide()
    Cliente.reset()
    Cliente.query({credito:true})      
    @html require("views/apps/auxiliares/emitirRecibo/layout")(@documento)
    @resetDates(@inputs_to_validate)
    
    new Clientes(el: @src_cliente)
    @item_loader.hide()
    
    Documento.bind "query_success" , @onLoadDocumentos
   
    Cliente.bind 'current_set' , (cliente) =>
      @codigo = parseInt(Math.random() * 10000)
      @txt_codigo.html @codigo
      Saldo.destroyAll()
      Recibo.destroyAll()
      Documento.query { cliente: cliente,saldo: true }
      @item_loader.show()

  onLoadDocumentos: =>
    documentos = Documento.all() 
    for documento in documentos
      documento.maxValue = documento.Saldo
      documento.minValue = 0
      if documento.Tipo_de_Documento == "NC"
        documento.maxValue = 0
        documento.minValue = documento.Saldo
    @documentos_list.html require("views/apps/auxiliares/emitirRecibo/saldo")(documentos) 
    @update_total()
    @item_loader.hide()

  add_saldo: (e) =>
    target = $(e.target)
    documento = Documento.find(target.attr("data-id"))
    target.parents('tr').find(".txt_saldo_pendiente_monto").val documento.Saldo
    @update_total()

  remove_saldo: (e) =>
    target = $(e.target)
    documento = Documento.find( target.attr("data-id") )
    target.parents('tr').find(".txt_saldo_pendiente_monto").val "0"
    target.val "0"
    @update_total()

  on_saldo_change: (e) =>
    target = $(e.target)
    @update_total()

  update_total: =>
    total = 0
    for raw_input in $("input.txt_saldo_pendiente_monto")
      input = $(raw_input)
      total += parseFloat(input.val())
    @lbl_total.html total.toMoney()

  #####
  # ACTIONS
  #####

  customValidation: =>
    @validationErrors.push "Debe escoger un cliente" if Cliente.current == null

  beforeSend: (object) =>
    documentos = []
    documentosList = ""
    montosList = ""
    consecutivosList= ""
    documentosLinks = ""
    monto = 0
    for index,value of object
      src = Documento.exists(index)
      if src
        item = { Documento: src.id ,Consecutivo: src.CodigoExterno , Monto: parseFloat(value) }
        documentos.push item
        monto += item.Monto
        documentosList += "#{src.id},"
        montosList += "#{item.Monto},"
        consecutivosList += "#{item.Consecutivo},"
        documentosLinks += '<a href="/' + item.Documento + '">' + item.Consecutivo + '</a><br/>'
        src.PagoEnRecibos = item.Monto
        src.save()

    montosList = montosList.substring(0,montosList.length-1)
    documentosList = documentosList.substring(0,documentosList.length-1)
    consecutivosList = consecutivosList.substring(0,consecutivosList.length-1)

    object.FechaFormaPago = object.FechaFormaPago.to_salesforce_date()
    object.Monto = monto
    object.Cliente = Cliente.current.id
    object.Documentos = JSON.stringify documentos
    object.DocumentosList = documentosList
    object.MontosList = montosList
    object.ConsecutivosList = consecutivosList
    object.DocumentosLinks = documentosLinks

  send: (e) =>
    @refreshElements()
    
    @recibo = { CodigoExterno: @codigo } if !@recibo
    @updateFromView(@recibo,@inputs_to_validate)
    @reciboSend = Recibo.create @recibo
    Spine.trigger "show_lightbox" , "sendRecibo" , @reciboSend , @after_send   

  after_send: =>
    @reset()

  reset: ->
    Documento.destroyAll()
    Recibo.destroyAll()
    @txt_codigo.empty()
    Cliente.reset_current()
    @recibo = null if @recibo
    @inputs_to_validate.val("")
    @resetDates(@inputs_to_validate)
    @documentos_list.empty()
    @lbl_total.empty()
    @navigate "/apps"
    

module.exports = EmitirRecibos
