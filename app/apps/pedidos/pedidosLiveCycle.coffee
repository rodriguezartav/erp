require('lib/setup')
Spine = require('spine')
Documento = require("models/documento")
Cliente = require("models/cliente")
Producto = require("models/producto")
PedidoPreparado = require("models/socketModels/pedidoPreparado")
Saldo = require("models/socketModels/saldo")

class PedidosLiveCycle extends Spine.Controller
  className: "row-fluid"

  @departamento = "Pedidos"
  @label = "Administracion de Pedidos"
  @icon = "icon-ok-sign"

  elements:
    ".error" : "error"
    ".src_pedidos_pendientes" : "src_pedidos_pendientes" 
    ".src_pedidos_archivados" : "src_pedidos_archivados"
    ".src_pedidos_aprobados" : "src_pedidos_aprobados"
    ".src_pedidos_facturados" : "src_pedidos_facturados"
    ".src_pedidos_anulados" : "src_pedidos_anulados"
    ".src_saldos" : "src_saldos"
    ".src_cliente" : "src_cliente"
    ".src_options" : "src_options"
    ".content" : "content"
    ".txt_observacion" : "txt_observacion"
    ".pedido_detail_info" : "pedido_detail_info"
    ".src_pedidos_list" : "src_pedidos_list"
    

  events:
    "click .cancel"   : "reset"
    "click .aprobar"  : "on_action_click"
    "click .archivar" : "on_action_click"
    "click .reload" : "reload"
    "click .pedidoItem"  : "onItemClick"

  constructor: ->
    super
    @error.hide()
    @html require("views/apps/pedidos/pedidosLiveCycle/layout")(PedidosLiveCycle)
    @renderPedidos()
    PedidoPreparado.bind "push_success" , @renderPedidos

  reload: ->
    PedidoPreparado.ajax().query( { especial: false }   , afterSuccess: @renderPedidos )    

  renderPedidos: =>
    aprobados= []
    archivados = []
    pendientes = []
    facturados = []
    anulados = []
    groups = []

    groups = PedidoPreparado.group_by_referencia(PedidoPreparado.all())
    for group in groups
      if group.Estado == 'Pendiente'
        saldos = Saldo.findAllByAttribute "Cliente" , group.Cliente
        pendientes.push group: group, saldos: saldos
      else
        aprobados.push group if group.Estado == "Aprobado"
        archivados.push group if group.Estado == "Archivado"
        facturados.push group if group.Estado == "Facturado"
        anulados.push group if group.Estado == "Anulado"

    @src_pedidos_list.html "<li><h5>No hay pedidos en la lista</h5></li>"
    @src_pedidos_pendientes.html require("views/apps/pedidos/pedidosLiveCycle/smartItemPendiente")( pendientes ) if pendientes.length > 0
    @src_pedidos_aprobados.html require("views/apps/pedidos/pedidosLiveCycle/smartItemAprobado")( aprobados) if aprobados.length > 0
    @src_pedidos_archivados.html require("views/apps/pedidos/pedidosLiveCycle/smartItemAnulado")( archivados ) if archivados.length > 0
    @src_pedidos_facturados.html require("views/apps/pedidos/pedidosLiveCycle/smartItemFacturado")( facturados ) if facturados.length > 0
    @src_pedidos_anulados.html require("views/apps/pedidos/pedidosLiveCycle/smartItemAnulado")( anulados ) if anulados.length > 0

  onItemClick: (e) =>
    target = $(e.target)
    target = target.parent() until target.attr "data-cliente"
    details = target.find(".pedidoDetails")
    status = details.is(":visible")
    @el.find(".pedidoDetails").hide()
    target.find(".pedidoDetails").show() if !status

  on_action_click: (e) =>
    target = $(e.target)
    referencia = target.attr "data-referencia"
    @newEstado = parseInt( target.attr("data-newEstado") )
    @pedidos = PedidoPreparado.findAllByAttribute "Referencia" , referencia
    @cliente = target.attr "data-cliente"
    observacion = @txt_observacion.val() || ""
    ids = []
    ids.push pedido.id for pedido in @pedidos

    data =
      class: PedidoPreparado
      restRoute: "Oportunidad"
      restMethod: "PUT"
      restData: ids: ids , observacion: observacion, newEstado: @newEstado

    Spine.trigger "show_lightbox" , "rest" , data , @aprobarSuccess
    return false;

  aprobarSuccess: (sucess,results) =>
    console.log arguments
    @notify()
    showInvoice = false
    for pedido in @pedidos
      if @newEstado == -1
        pedido.Estado = "Anulado"
      else if @newEstado == 0
        pedido.Estado = "Archivado"
      else if @newEstado == 1
        pedido.Estado = "Pendiente"
      else if @newEstado == 2
        pedido.Estado = "Aprobado"
      else if @newEstado == 3        
        pedido.Estado = "Facturado"
        showInvoice=true
      pedido.save()

    @newEstado = null
    @pedidos = null
    @cliente = null
    @renderPedidos()

    url = Spine.session.instance_url + "/apex/invoice_topdf?Documento__c_id=" + results?.response
    window.open(url) if showInvoice

  notify: =>
    #cliente = Cliente.find @cliente
    #verb = if @aprobar == 1 then "Aprobe" else "Archive"
    #Spine.socketManager.pushToFeed("#{verb} un pedido de #{clinte.Name}") 

    #Spine.throttle ->
     # Spine.socketManager.pushToProfile("Ejecutivo Ventas" , "#{verb} varios pedidos, pueden proceder a revisarlos.")
    #, 15000

  reset: ->
    PedidoPreparado.unbind "push_success" , @renderPedidos
    @el.find('.popable').popover("hide")
    $('.popover').hide()
    @release()
    @navigate "/apps"

module.exports = PedidosLiveCycle