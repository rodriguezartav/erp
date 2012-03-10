require('lib/setup')
Spine = require('spine')
Clientes = require("controllers/clientes")
Documento = require("models/documento")
Cliente = require("models/cliente")
Cuenta = require("models/cuenta")
User = require("models/user")

class Main extends Spine.Controller
  className: "columns nine"

  elements:
    ".forma_pago>.list" : "forma_pago_list"
    ".forma_pago>.total" : "forma_pago_total"
    ".saldos_pendientes .list" :"saldos_pendientes_list"
    ".saldos_pendientes>.total" : "saldos_pendientes_total"

  events:
    "click .btn_forma" : "forma_pago_add_item"
    "click .remove_forma_pago" : "forma_pago_remove_item"
    "click .btn_apply_deposito" : "saldos_pendientes_update_total_apply_deposito"
    "change input.txt_forma_pago_monto" : "forma_pago_update_total"
    "change input.txt_saldo_pendiente_monto" : "saldos_pendientes_update_total"

  constructor: ->
    super
    @html require("views/apps/pagos/landing")
    Documento.bind "refresh" , @render_documentos
    @total_depositos = 0
    Cliente.reset_current()
    Cliente.bind 'current_set' , (cliente) =>
      @html require("views/apps/pagos/layout")
      Documento.fetch_from_sf cliente , User.current
    
  render_documentos: =>
    @documentos = Documento.all()
    @log @saldos_pendientes_list
    @saldos_pendientes_list.html require("views/apps/pagos/saldo")(@documentos)

  forma_pago_add_item: (e) ->
    target = $(e.target)
    type = target.attr "data-type"
    @forma_pago_list.append require("views/apps/pagos/forma_pago_" + type)
    
  forma_pago_remove_item: (e) ->
    @log e
    target = $(e.target)
    target.parents('tr').remove()

  forma_pago_update_total: (e) =>
    target = $(e.target)
    items = target.parent().find('input.txt_forma_pago_monto')
    total_depositos = @total_depositos = 0
    items.each ->
      total_depositos += parseFloat @value
    @total_depositos = total_depositos
    @forma_pago_total.html @total_depositos.toMoney()

  saldos_pendientes_update_total_apply_deposito: (e) =>
    return false if @total_depositos <= 0
    target = $(e.target)
    includeNotas = target.attr "data-include_notas"
    running_total = @total_depositos
    for documento in @saldos_pendientes_list.find('input.txt_saldo_pendiente_monto')
      if running_total > 0
        doc = $(documento)
        doc_total = doc.attr "data-max"
        if running_total - doc_total > 0
          documento.value = doc_total
          running_total -= doc_total
        else
          documento.value =  doc_total - running_total
          running_total = 0
    @saldos_pendientes_update_total()
    
  saldos_pendientes_update_total: =>
    @total_saldos_pendientes = 0
    for documento in @saldos_wrapper.find('input.txt_saldo_pendiente_monto')
      @total_saldos_pendientes += documento.value
    @log @saldos_pendientes_total
    @log @total_saldos_pendientes
    @saldos_pendientes_total.html @total_saldos_pendientes.toMoney()

class Recibos extends Spine.Controller
  className: "app row"

  constructor: ->
    super
    clientes = new Clientes
    main  = new Main
    @append clientes,main
    Documento.bind "refresh" , @on_documento_refresh
    Cliente.fetch_from_sf(User.current)
    Cuenta.fetch_from_sf(User.current)

  on_documento_refresh: () =>
    documentos = Documento.all()
    Cliente.current.Documentos = documentos
    Cliente.current.save()

module.exports = Recibos





