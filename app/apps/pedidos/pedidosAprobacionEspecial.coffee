require('lib/setup')
Spine = require('spine')
Documento = require("models/documento")
Cliente = require("models/cliente")
Producto = require("models/producto")
PedidoPreparado = require("models/socketModels/pedidoPreparado")
Cuenta = require("models/cuenta")
User = require("models/user")

class PedidosAprobacionEspecial extends Spine.Controller
  className: "row-fluid"

  @departamento = "Pedidos"
  @label = "Aprobacion de Pedidos Especiales"
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
    @html require("views/apps/pedidos/pedidosAprobacion/layout")(PedidosAprobacionEspecial)
    @renderPedidos()
    PedidoPreparado.bind "query_success" , @renderPedidos
    PedidoPreparado.bind "push_success" , @renderPedidos

  reload: ->
    PedidoPreparado.query({ especial: true })

  renderPedidos: =>
    pedidos = PedidoPreparado.select (pedido) ->
      return true if pedido.Estado == "Pendiente" and pedido.Especial == true
    @groups = PedidoPreparado.group_by_referencia(pedidos)
    @src_pedidos.html require("views/apps/pedidos/pedidosAprobacion/item")(@groups)

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
    Spine.trigger "show_lightbox" , "aprobarPedidos" , {group: group , aprobar: aprobar} , @aprobarSuccess

  aprobarSuccess: =>
    for pedido in @aprovedGroup.Pedidos
      pedido.destroy()
    @aprovedGroup = null
    @aprobar = null
    @renderPedidos()

  reset: ->
    PedidoPreparado.unbind "query_success" , @onLoadPedidos
    PedidoPreparado.unbind "push_success" , @renderPedidos
    @release()
    @navigate "/apps"

module.exports = PedidosAprobacionEspecial