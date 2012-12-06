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
    

  events:
    "click .cancel"   : "reset"
    "click .btn_aprobar"  : "onAprobar"
    "click .btn_facturar" : "onFacturar"
    "click .reload" : "reload"
    "click .item"  : "onItemClick"

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
    aprobados= []
    pendientes = []
    facturados = []

    for documento in Documento.all()
      aprobados.push documento if documento.Autorizado == true
      facturados.push documento if documento.Estado == "Impreso"
      pendientes.push documento if documento.Autorizado == false

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

  onAprobar: =>
    target = $(e.target)
    id = target.data "id"
    documento = Documento.find id
    documento.Autorizado = true;
    documento.save()
    
  onFacturar: =>
    target = $(e.target)
    id = target.data "id"
    documento = Documento.find id    
    #send to print

  on_action_click: (e) =>
    target = $(e.target)
    referencia = target.attr "data-referencia"
    @newEstado = parseInt( target.attr("data-newEstado") )
    @pedidos = PedidoPreparado.findAllByAttribute "Referencia" , referencia
    @cliente = target.attr "data-cliente"
    observacion = @txt_observacion.val() || ""
    ids = []
    ids.push pedido.id for pedido in @pedidos

    #data =
    #  class: PedidoPreparado
    #  restRoute: "Oportunidad"
    #  restMethod: "PUT"
    #  restData: ids: ids , observacion: observacion, newEstado: @newEstado

    #Spine.trigger "show_lightbox" , "rest" , data , @aprobarSuccess
    #return false;

  aprobarSuccess: (sucess,results) =>
    @notify()
    @render()

    url = Spine.session.instance_url + "/apex/invoice_topdf?Documento__c_id=" + results?.response
    window.open(url) if showInvoice

  notify: =>
#    cliente = Cliente.find @cliente
 #   Spine.socketManager.pushToFeed("#{verb} un pedido de #{cliente.Name}") 

  reset: ->
    Documento.unbind "refresh" , @renderPedidos
    @release()
    @navigate "/apps"

module.exports = NotasLivecycle