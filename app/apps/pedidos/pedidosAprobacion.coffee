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
    ".src_pedidos" : "src_pedidos" 
    ".content" : "content"

  events:
    "click .cancel"   : "reset"
    "click .aprobar"  : "on_action_click"
    "click .archivar" : "on_action_click"
    "click .reload" : "reload"

  constructor: ->
    super
    @error.hide()
    @html require("views/apps/pedidos/pedidosAprobacion/layout")(PedidosAprobacion)
    @renderPedidos()
    PedidoPreparado.bind "query_success" , @renderPedidos
    PedidoPreparado.bind "push_success" , @renderPedidos

  reload: ->
    PedidoPreparado.query({ especial: false })

  renderPedidos: =>
    pedidos = PedidoPreparado.select (pedido) ->
      return true if pedido.Estado == "Pendiente" and !pedido.Especial
    @groups = PedidoPreparado.group_by_referencia(pedidos)
    @src_pedidos.empty()
    for group in @groups
      @saldos = Saldo.findAllByAttribute "Cliente" , group.Cliente
      @src_pedidos.append require("views/apps/pedidos/pedidosAprobacion/item")(groups: group , saldos: @saldos)
    @el.find('.popable').popover()

  on_action_click: (e) =>
    target = $(e.target)
    referencia = target.attr "data-referencia"
    aprobar = parseInt(target.attr("data-aprobar"))
    group = null
    for g in @groups
      if g.Referencia == referencia
        group = g

    return false if !group
    @aprovedGroup = group
    @aprobar = aprobar
    Spine.trigger "show_lightbox" , "aprobarPedidos" , {group: group , aprobar: aprobar , allowOverDraft: false , allowOver60: false} , @aprobarSuccess

  aprobarSuccess: =>
    @notify() if @aprobar == 1
    for pedido in @aprovedGroup.Pedidos
      pedido.destroy()
    @aprovedGroup = null
    @aprobar = null
    @renderPedidos()

  notify: =>
    Spine.throttle ->
      Spine.SocketManager.pushToProfiles("Encargado Ventas" , "Aprobando varios pedidos, pueden facturar.")
    , 60000

  reset: ->
    PedidoPreparado.unbind "query_success" , @onLoadPedidos
    PedidoPreparado.unbind "push_success" , @renderPedidos
    @el.find('.popable').popover("hide")
    @release()
    @navigate "/apps"

module.exports = PedidosAprobacion