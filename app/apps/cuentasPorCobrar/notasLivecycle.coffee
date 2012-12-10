require('lib/setup')
Spine = require('spine')
Documento = require("models/documento")
Cliente = require("models/cliente")

class NotasLivecycle extends Spine.Controller
  className: "row-fluid"

  @departamento = "Credito y Cobro"
  @label = "Administracion de Notas"
  @icon = "icon-ok-sign"

  elements:
    ".error" : "error"
    ".src_pendientes" : "srcPendientes" 
    ".src_aprobados" : "srcAprobados"
    ".src_facturados" : "srcFacturados"
    ".src_list" : "srcList"
    ".view" : "view"
    ".print" : "print"    

  events:
    "click .cancel"   : "reset"
    "click .btn_aprobar"  : "onAprobar"
    "click .btn-print" : "onPrint"
    "click .reload" : "reload"
    "click .item"  : "onItemClick"
    "click .btn-print-complete" : "onPrintComplete"

  constructor: ->
    super
    @error.hide()
    @html require("views/apps/cuentasPorCobrar/notasLivecycle/layout")(NotasLivecycle)
    @render()
    @reload()
    Documento.bind "refresh" , @render

  reload: ->
    Documento.destroyAll()
    Documento.ajax().query( livecycle: true )

  render: =>
    @view.show()
    @print.hide()

    aprobados= []
    pendientes = []
    facturados = []

    for documento in Documento.all()
      if documento.Estado == "Impreso"
        facturados.push documento 
      else if documento.Autorizado == true
        aprobados.push documento
      else if documento.Autorizado == false
        pendientes.push documento 

    @srcList.html "<li><h5>No hay documentos en la lista</h5></li>"
    @srcPendientes.html require("views/apps/cuentasPorCobrar/notasLivecycle/smartItemPendiente")( pendientes ) if pendientes.length > 0
    @srcAprobados.html require("views/apps/cuentasPorCobrar/notasLivecycle/smartItemAprobado")( aprobados) if aprobados.length > 0
    @srcFacturados.html require("views/apps/cuentasPorCobrar/notasLivecycle/smartItemFacturado")( facturados ) if facturados.length > 0

  onItemClick: (e) =>
    target = $(e.target)
    target = target.parent() until target.hasClass "item"
    details = target.find(".details")
    status = details.is(":visible")
    @el.find(".details").hide()
    details.show() if !status

  onAprobar: (e) =>
    target = $(e.target)
    id = target.data "id"
    documento = Documento.find id
    documento.Autorizado = true;
    documento.save()

    data =
      class: Documento
      restRoute: "Saldo"
      restMethod: "POST"
      restData: id :  documento.id

    Spine.trigger "show_lightbox" , "rest" , data , @render
    
  onPrint: (e) =>
    @view.hide()
    @print.show()
    target = $(e.target)
    id = target.data "id"
    @documento = Documento.find id    
    @print.html require("views/apps/cuentasPorCobrar/notasLivecycle/printHeader")
    @print.append require("views/apps/cuentasPorCobrar/notasLivecycle/printNota")(@documento)
    @print.append require("views/apps/cuentasPorCobrar/notasLivecycle/printNota")(@documento)



  onPrintComplete: =>
    @view.show()
    @print.hide()
    @documento.Estado = "Impreso";
    @documento.save()
    
    data =
      class: Documento
      restRoute: "Saldo"
      restMethod: "PUT"
      restData: id :  @documento.id

    Spine.trigger "show_lightbox" , "rest" , data , @render

    @documento = null;

  reset: ->
    @documento = null;
    Documento.unbind "refresh" , @renderPedidos
    @release()
    @navigate "/apps"

module.exports = NotasLivecycle