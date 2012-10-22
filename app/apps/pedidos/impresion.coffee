require('lib/setup')
Spine = require('spine')
Documento = require("models/documento")
Cliente = require("models/cliente")
Producto = require("models/producto")
PedidoPreparado = require("models/socketModels/pedidoPreparado")
Saldo = require("models/socketModels/saldo")

class PedidosAprobacion extends Spine.Controller
  className: "row-fluid"

  @departamento = "Pedidos"
  @label = "Aprobacion"
  @icon = "icon-ok-sign"

  elements:
    ".error" : "error"
    ".src_pedidos_pendientes" : "src_pedidos_pendientes" 
    ".src_pedidos_archivados" : "src_pedidos_archivados"
    ".src_pedidos_aprobados" : "src_pedidos_aprobados"
    ".src_pedidos_facturados" : "src_pedidos_facturados"
    ".src_saldos" : "src_saldos"
    ".src_cliente" : "src_cliente"
    ".src_options" : "src_options"
    ".content" : "content"
    ".txt_observacion" : "txt_observacion"
    ".pedido_detail_info" : "pedido_detail_info"
    

  events:
    "click .cancel"   : "reset"
    "click .aprobar"  : "on_action_click"
    "click .archivar" : "on_action_click"
    "click .reload" : "reload"
    "click .pedidoItem"  : "onItemClick"

  constructor: ->
    super
    @error.hide()
    @html require("views/apps/pedidos/pedidosAprobacion/layout")(PedidosAprobacion)
    @renderPedidos()
    PedidoPreparado.bind "push_success" , @renderPedidos

  reload: ->
    PedidoPreparado.ajax().query( { especial: false }   , afterSuccess: @renderPedidos )    

  renderPedidos: =>
    aprobados= []
    archivados = []
    pendientes = []
    facturados = []
    for pedido in PedidoPreparado.all()
      aprobados.push pedido if pedido.Estado == "Aprobado"
      archivados.push pedido if pedido.Estado == "Archivado"
      pendientes.push pedido if pedido.Estado == "Pendiente"
      facturados.push pedido if pedido.Estado == "Facturado"

    @src_pedidos_aprobados.html require("views/apps/pedidos/pedidosAprobacion/smartItem")( PedidoPreparado.group_by_referencia(aprobados) ) if aprobados.length > 0
    @src_pedidos_pendientes.html require("views/apps/pedidos/pedidosAprobacion/smartItem")( PedidoPreparado.group_by_referencia(pendientes) )  if pendientes.length > 0
    @src_pedidos_archivados.html require("views/apps/pedidos/pedidosAprobacion/smartItem")( PedidoPreparado.group_by_referencia(archivados) )  if archivados.length > 0
    @src_pedidos_facturados.html require("views/apps/pedidos/pedidosAprobacion/smartItem")( PedidoPreparado.group_by_referencia(facturados) )  if facturados.length > 0

    @src_saldos.empty()
    @src_cliente.empty()
    @src_options.empty()

  onItemClick: (e) =>
    target = $(e.target)
    target = target.parent() until target.attr "data-cliente"
    @el.find(".pedido_detail_info").empty()
    @el.find(".pedidoItems").hide()
    target.find(".pedidoItems").show()
    @showPedidoCreditDetails(target) if target.attr("data-estado") == "Pendiente"
      
  showPedidoCreditDetails: (target) =>
    cliente = target.attr "data-cliente"
    referencia = target.attr "data-referencia"
    saldos = Saldo.findAllByAttribute "Cliente" , cliente
    @src_saldos.html require("views/apps/pedidos/pedidosAprobacion/smartSaldo")(saldos)
    @src_cliente.html require("views/apps/pedidos/pedidosAprobacion/smartCliente")(Cliente.find cliente)
    @src_options.html require("views/apps/pedidos/pedidosAprobacion/smartOptions")(PedidoPreparado.findByAttribute "Referencia" , referencia)

  on_action_click: (e) =>
    target = $(e.target)
    referencia = target.attr "data-referencia"
    @aprobar = parseInt( target.attr("data-aprobar") )
    @pedidos = PedidoPreparado.findAllByAttribute "Referencia" , referencia
    @cliente = target.attr "data-cliente"
    observacion = @txt_observacion.val() || ""
    ids = []
    ids.push pedido.id for pedido in @pedidos

    data =
      class: PedidoPreparado
      restRoute: "Oportunidad"
      restMethod: "PUT"
      restData: ids: ids , observacion: observacion, aprobar: @aprobar

    Spine.trigger "show_lightbox" , "rest" , data , @aprobarSuccess

  aprobarSuccess: =>
    @notify()
    for pedido in @pedidos
      pedido.Estado = if @aprobar then "Aprobado" else "Archivado"
      pedido.save()
    @aprobar = null
    @pedidos = null
    @cliente = null
    @renderPedidos()

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

module.exports = PedidosAprobacion