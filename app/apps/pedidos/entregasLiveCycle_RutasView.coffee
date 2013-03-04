Spine = require('spine')
Documento = require("models/socketModels/facturaEntregada")
Movimiento = require("models/movimiento")
Cliente = require("models/cliente")
PedidoPreparado = require("models/socketModels/pedidoPreparado")
Ruta  =  require("models/ruta")
Rutas =  require("apps/pedidos/entregasLiveCycle_RutasView")

class entregasLiveCycle_RutasView extends Spine.Controller
  className: "row-fluid"

  events:
    "click .btn_remove_ruta" : "onRutaRemove"
    "click .btn_remove_documento" : "onDocumentoRemove"

    "change .txtEntregadoDetail" : "onTxtEntregadoValorChange"
    "click .txtEntregadoDetail"  : "onTxtEntregadoDetailClick"
    "keypress .txtEntregadoDetail" : "onTxtEntregadoEnter"

    "change .txtRutaDetail" : "onTxtRutaDetailValorChange"
    "click .txtRutaDetail"  : "onTxtRutaDetailDetailClick"
    "keypress .txtRutaDetail" : "onTxtRutaDetailEnter"

    "click .btn_print_ruta" : "onPrintRuta"
    "click .btn_print_boleta" : "onPrintBoleta"
    "click .btn_completar_ruta"  : "onCompletarRuta"
    "click .btn_filter_rutas" : "onBtnFilterRutas"
    "click .btn_print_ruta_item" : "onPrintRutaItem"
 
  elements: 
    ".dropdownContainer" : "dropdownContainer"
 
  constructor: (@el , @print , @entregasLiveCycle) ->
    super
    Ruta.destroyAll()
    Ruta.bind "create update destroy" , @render
    Documento.bind "push_success" , @render

  render: =>
    rutas = Ruta.all()
    rutas = rutas.sort (a,b) ->
      f1 = new Date(a.Fecha)
      f2 = new Date(b.Fecha)
      return f1 - f2
    @html require("views/apps/pedidos/entregasLiveCycle/ruta")(rutas)

    @el.width( ( 168 * ( rutas.length + 1 ) ) + 'px')

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

  onTxtRutaDetailDetailClick: (e) =>
    $(e.target).select()
    return false
    
  onTxtRutaDetailEnter: (e) =>
    return false if e.keyCode == 13

  onTxtRutaDetailValorChange: (e) =>
    e.preventDefault()
    target = $(e.target)
    type = target.data "type"
    ruta = Ruta.findByName target.data "name"
    return false if !ruta
    docs = Documento.findAllByAttribute "EntregadoRuta" , ruta.Name

    ruta[type] = target.val()
    ruta.Name = Ruta.updateName(ruta)
    ruta.save()
    for doc in docs
      doc["EntregadoRuta"] = ruta.Name
      doc.save()
    @entregasLiveCycle.updateDocumentos(docs , @onRutaUpdateSuccess)
    return false

  onRutaUpdateSuccess: =>
    @render()

  onRutaRemove: (e) =>
    target = $(e.target)
    rutaLi = target.parents(".rutaLi")
    rutaName = rutaLi.data "name"
    return Spine.trigger "show_lightbox", "showError" , error: "La ruta tiene documentos, borrelos primero." if Documento.findByRuta(rutaName).length > 0
    ruta = Ruta.findByName rutaName
    ruta.destroy()

  onDocumentoRemove: (e) =>
    target = $(e.target)
    rutaLi = target.parents(".rutaLi")
    ruta = Ruta.findByName rutaLi.data "name"
    id = target.data "id"
    doc = Documento.exists id

    if doc
      doc.EntregadoRuta = " "
      doc.EntregadoValor = " "
      doc.EntregadoGuia = " "
      doc.EntregadoEmpaque = " "
      doc.save()
      @entregasLiveCycle.updateDocumento(doc)
    
    if ruta
      index = ruta.Documentos.indexOf id
      if index > -1
        ruta.Documentos.splice index , 1
        ruta.save()

  onBtnFilterRutas: (e) =>
    target = $(e.target)
    rutaLi = target.parents(".rutaLi")
    rutaName = rutaLi.data "name"
    documentos = []
    rutas = []
    for documento in Documento.findAllByAttribute "EntregadoRuta" , rutaName
      cliente = Cliente.find documento.Cliente
      rutas.addUniqueItem cliente.RutaTransporte
    @entregasLiveCycle.filterByRuta rutas

  onPrintRuta: (e) =>
    target = $(e.target)
    rutaLi = target.parents(".rutaLi")
    rutaName = rutaLi.data("name")
    ruta = Ruta.findByName rutaName
    @print.html require("views/apps/pedidos/entregasLiveCycle/printRuta")(ruta)
    
    for doc in Documento.findAllByAttribute "EntregadoRuta" , rutaName
      mov = Movimiento.findAllByAttribute("Documento" , doc.id)
      @print.append require("views/apps/pedidos/entregasLiveCycle/printRosada")(documento: doc, movimientos: mov)
    window.print()

  onPrintBoleta: (e) =>
    target = $(e.target)
    rutaLi = target.parents(".rutaLi")
    rutaName = rutaLi.data "name"
    @print.html ""

    for doc in Documento.findAllByAttribute "EntregadoRuta" , rutaName
      if !doc.hasEntregadoEmpaque()
        mov = Movimiento.findAllByAttribute("Documento" , doc.id)
        @print.append require("views/apps/pedidos/entregasLiveCycle/printBoleta")(documento: doc, movimientos: mov)
    @print.find("div:last-child").css("page-break-after","avoid")
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
    rutaLi = target.parents(".rutaLi")
    ruta = Ruta.findByName rutaLi.data "name"

    @ruta = ruta
    documentos = []
    for doc in ruta.Documentos
      documento = Documento.find doc
      documento.FechaEntrega = new Date()
      documento.Entregado = true
      documentos.push documento
    @entregasLiveCycle.updateDocumentos(documentos , @onCompletarRutaSuccess )

  onCompletarRutaSuccess: =>
    @ruta.destroy?();
    @entregasLiveCycle.reset()

  reset: =>
    Ruta.unbind "create update destroy" , @render
    Documento.unbind "push_success" , @render
    @release

module.exports = entregasLiveCycle_RutasView