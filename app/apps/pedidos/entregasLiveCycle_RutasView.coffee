Spine = require('spine')
Documento = require("models/socketModels/facturaEntregada")
Movimiento = require("models/movimiento")
Cliente = require("models/cliente")
PedidoPreparado = require("models/socketModels/pedidoPreparado")
Ruta  =  require("models/transitory/ruta")
Rutas =  require("apps/pedidos/entregasLiveCycle_RutasView")

class entregasLiveCycle_RutasView extends Spine.Controller
  className: "row-fluid"

  events:
    "click .btn_remove_ruta" : "onRutaRemove"
    "click .btn_remove_documento" : "onDocumentoRemove"
    "change .txtEntregadoDetail" : "onTxtEntregadoValorChange"
    "click .txtEntregadoDetail"  : "onTxtEntregadoDetailClick"
    "keypress .txtEntregadoDetail" : "onTxtEntregadoEnter"
    "click .btn_print_ruta" : "onPrintRuta"
    "click .btn_print_boleta" : "onPrintBoleta"
    "click .btn_completar_ruta"  : "onCompletarRuta"
    "click .btn_filter_rutas" : "onBtnFilterRutas"
    "click .btn_print_ruta_item" : "onPrintRutaItem"
 
  elements: 
    ".dropdownContainer" : "dropdownContainer"
 
  constructor: (@el , @print , @entregasLiveCycle) ->
    super
    @html require("views/apps/pedidos/entregasLiveCycle/layoutRutas")(@)
    Ruta.bind "create update destroy" , @render
    Documento.bind "push_success" , @render

  render: =>
    rutas = Ruta.all()
    rutas = @createRutasFromDocumentos() if rutas.length == 0
    rutas = rutas.sort (a,b) ->
      f1 = new Date(a.Fecha)
      f2 = new Date(b.Fecha)
      return f1 - f2
    @html require("views/apps/pedidos/entregasLiveCycle/ruta")(rutas)

  createRutasFromDocumentos: =>
    documentos = Documento.select (item) ->
      return true if item.hasEntregadoRuta()
      return false

    tempRutas = {}
    for documento in documentos
      ruta = tempRutas[documento.EntregadoRuta] or Ruta.tempFromString documento.EntregadoRuta
      ruta.Documentos.push documento.id
      tempRutas[documento.EntregadoRuta]  = ruta

    rutas = []
    rutas.push ruta for index,ruta of tempRutas
    return rutas

  onTxtEntregadoDetailClick: (e) =>
    $(e.target).select()
    return false

  onTxtEntregadoEnter: (e) ->
    return false if e.keyCode == 13

  onTxtEntregadoValorChange: (e) =>
    e.preventDefault()
    target = $(e.target)
    type = target.data "type"
    id = target.data "id"
    doc = Documento.find id
    doc[type] = target.val()
    doc.save()
    @entregasLiveCycle.updateDocumento(doc)
    @render()
    return false

  onRutaRemove: (e) =>
    target = $(e.target)
    id = target.data "id"
    ruta = Ruta.find id
    return Spine.trigger "show_lightbox", "showError" , error: "La ruta tiene documentos, borrelos primero." if ruta.Documentos.length > 0
    ruta.destroy()

  onDocumentoRemove: (e) =>
    target = $(e.target)
    id = target.data "id"
    doc = Documento.find id
    doc.EntregadoRuta = " "
    doc.EntregadoValor = " "
    doc.EntregadoGuia = " "
    doc.EntregadoEmpaque = " "
    doc.save()
    @entregasLiveCycle.updateDocumento(doc)

    ruta = target.data "ruta"
    ruta = Ruta.find ruta
    index = ruta.Documentos.indexOf id
    if index > -1
      ruta.Documentos.splice index , 1
      ruta.save()

  onBtnFilterRutas: (e) =>
    target = $(e.target)
    id = target.data "id"
    ruta = Ruta.find id
    documentos = []
    rutas = []
    for documentoId in ruta.Documentos
      documento = Documento.find documentoId 
      cliente = Cliente.find documento.Cliente
      rutas.addUniqueItem cliente.RutaTransporte
    @entregasLiveCycle.filterByRuta rutas

  onPrintRuta: (e) =>
    target = $(e.target)
    id = target.data "id"
    ruta = Ruta.find id
    @print.html require("views/apps/pedidos/entregasLiveCycle/printRuta")(ruta)
    
    for docId in ruta.Documentos
      doc = Documento.find docId
      mov = Movimiento.findAllByAttribute("Documento" , docId)
      @print.append require("views/apps/pedidos/entregasLiveCycle/printRosada")(documento: doc, movimientos: mov)
    $("body").addClass "label"
    window.print()

  onPrintBoleta: (e) =>
    target = $(e.target)
    id = target.data "id"
    ruta = Ruta.find id
    @print.html ""

    for docId in ruta.Documentos
      doc = Documento.find docId
      if !doc.hasEntregadoEmpaque()
        mov = Movimiento.findAllByAttribute("Documento" , docId)
        @print.append require("views/apps/pedidos/entregasLiveCycle/printBoleta")(documento: doc, movimientos: mov)
    @print.find("div:last-child").css("page-break-after","avoid")
    $('head').append('<link href="print.css" title="printLandscape" rel="stylesheet" />');
    window.print()

  onPrintRutaItem: (e) =>
    target = $(e.target)
    id = target.data "id"
    doc = Documento.find id
    mov = Movimiento.findAllByAttribute("Documento" , doc.id)
    @print.html require("views/apps/pedidos/entregasLiveCycle/printBoleta")(documento: doc, movimientos: mov)
    @print.find("div:last-child").css("page-break-after","avoid")
    window.print()

  onCompletarRuta: (e) =>
    target = $(e.target)
    id = target.data "id"
    ruta = Ruta.find id
    @ruta = ruta
    documentos = []
    for doc in ruta.Documentos
      documento = Documento.find doc
      documento.FechaEntrega = new Date()
      documento.Entregado = true
      documentos.push documento
    
    @entregasLiveCycle.updateDocumentos(documentos , @onCompletarRutaSuccess )

  onCompletarRutaSuccess: =>
    @ruta.destroy();
    @entregasLiveCycle.reset()

  reset: =>
    Ruta.unbind "create update destroy" , @render
    Documento.unbind "push_success" , @render
    @release

module.exports = entregasLiveCycle_RutasView