require('lib/setup')
Spine = require('spine')
Saldo = require("models/sobjects/saldo")
Cliente = require("models/cliente")
Clientes = require("controllers/clientes")
Producto = require("models/producto")
Documento = require("models/documento")
Recibo = require("models/recibo")
ReciboItem = require("models/transitory/reciboItem")

class ReciboItems extends Spine.Controller  
  tag: "tr"

  elements:
    "input"  : "txt_monto"

  events:
    "click .incluir" : "add_saldo"
    "click .excluir" : "remove_saldo"
    "change .txt_saldo_pendiente_monto" : "on_monto_change"

  constructor: ->
    super
    @render()
  
  render: =>
    @html require("views/apps/auxiliares/emitirRecibo/reciboItem")(@reciboItem) 

  add_saldo: (e) =>
    @reciboItem.Monto = @reciboItem.Saldo
    @reciboItem.save()
    @render()
    
  remove_saldo: (e) =>
    @reciboItem.Monto = 0
    @reciboItem.save()
    @render()

  on_monto_change: (e) =>
    @reciboItem.Monto = @txt_monto.val()
    @reciboItem.save()
    @render()

class Recibos extends Spine.Controller
  @extend Spine.Controller.ViewDelegation

  className: "row-fluid reciboItem"

  elements:
    ".error"                      : "error"
    ".validatable"                : "inputs_to_validate"
    ".lbl_total"                  : "lbl_total"
    ".well"                       : "well"
    ".recibo_items_list"          : "recibo_items_list"
    ".alert_box"                  : "alert_box"

  events:
    "click .send"    : "send"
    "click .save"    : "save"
    "click .print"   : "print"
    "click .close"   : "reset"
    "click .well"    : "toggleWellOn"

  constructor: ->
    super
    @html require("views/apps/auxiliares/emitirRecibo/recibo")(@recibo)
    @refreshView(@recibo,@inputs_to_validate)
    @reciboItems = []
    @addReciboItems()

  addReciboItems: ->  
    reciboItems = ReciboItem.findAllByAttribute("CodigoExterno", @recibo.CodigoExterno )    
    for ri in reciboItems
      reciboItem = new ReciboItems(reciboItem: ri)
      @reciboItems.push reciboItem
      @recibo_items_list.append reciboItem.el

  ##
  # View Functions
  ##

  toggleWellOn: (e) =>
    return false if @well.hasClass "selected"
    $(".reciboItem>.well").removeClass "selected"
    @well.addClass "selected"

  toggleWellOff: =>
    return false if(!@well.hasClass("selected"))
    $(".reciboItem>.well").removeClass "selected"

  ##
  # Persistance Functions
  ##

  save: (e) =>
    @refreshElements()
    @updateFromView(@recibo,@inputs_to_validate)
    @recibo.save()
    @alert_box.html require("views/alert")(message: "Listo! Se han guardado los cambios..")
    window.setTimeout => 
      @alert_box.empty()  
    , 1400 

  beforeSend: (object) =>
    reciboItems = ReciboItem.findAllByAttribute("CodigoExterno", object.CodigoExterno )
    object.MontosList = ""
    object.DocumentosList = ""
    object.ConsecutivosList = ""
    object.Monto = 0;
    for item in reciboItems
      object.DocumentosList += "#{item.SaldoId},"
      object.MontosList += "#{item.Monto},"
      object.ConsecutivosList += "#{item.Consecutivo},"
      object.DocumentosLinks += '<a href="/' + item.Documento + '">' + item.Consecutivo + '</a><br/>'
      object.Monto += item.Monto
    object.MontosList = object.MontosList.substring(0,object.MontosList.length-1)
    object.DocumentosList = object.DocumentosList.substring(0,object.DocumentosList.length-1)
    object.ConsecutivosList = object.ConsecutivosList.substring(0,object.ConsecutivosList.length-1)
    object.save()
    
  send: (e) =>
    @refreshElements()
    @updateFromView(@recibo,@inputs_to_validate)
    @recibo.save()
    Spine.trigger "show_lightbox" , "sendRecibo" , @recibo , @after_send   
   
  after_send: =>
    @destroyData()
    @toggleWellOff()
    @reset()
 
  destroyData: =>
    for ri in ReciboItem.findAllByAttribute("CodigoExterno", @recibo.CodigoExterno )
      ri.destroy()
    @recibo.destroy()
   
  reset: () ->
    if !@toggleWellOff()
      @destroyData()
      @release()

class EmitirRecibos extends Spine.Controller
  @departamento = "Tesoreria"
  @label = "Emitir Recibos"

  elements:
    ".src_cliente"      :  "src_cliente"
    ".js_create_recibo"  :  "btn_create_recibo"
    
  events:
    "click .js_create_recibo" : "on_create_recibo_click"
    "click .cancel" : "reset"

  constructor: ->
    super
    @recibos = []
    Cliente.reset()
    @html require("views/apps/auxiliares/emitirRecibo/layout")(EmitirRecibos)
    @btn_create_recibo.hide()
    new Clientes(el: @src_cliente)
    Cliente.bind 'current_set' , @on_cliente_set
    @renderRecibos()

  on_cliente_set: (cliente) =>
    @btn_create_recibo.show()

  on_create_recibo_click: =>
    @createRecibo()

  renderRecibos: =>
    for recibo in Recibo.all()
      @createRecibo(recibo)

  createRecibo: (recibo=false) =>
    if !recibo
      codigo = parseInt(Math.random() * 10000)
      recibo = Recibo.create { CodigoExterno: codigo, Cliente:  Cliente.current.id , FechaFormaPago: new Date() }
      saldosAll = Saldo.all()
      saldos = []
      for saldo in saldosAll
        saldos.push saldo if saldo.Cliente == recibo.Cliente and saldo.Saldo != 0
      ReciboItem.createFromSaldos( saldos , recibo )

    ri = new Recibos(recibo: recibo)
    @recibos.push ri 
    @append ri

  reset: (redirect) ->
    for recibo in @recibos
      recibo.release()
    Cliente.unbind 'current_set' , @on_cliente_set
    @navigate "/apps"

module.exports = EmitirRecibos
