require('lib/setup')
Spine = require('spine')
Documento = require("models/documento")
Cliente = require("models/cliente")
Producto = require("models/producto")
PedidoPreparado = require("models/socketModels/pedidoPreparado")
Cuenta = require("models/cuenta")
User = require("models/user")

class PedidosAprobacion extends Spine.Controller
  className: "row-fluid"

  @departamento = "Credito y Cobro"
  @label = "Aprobacion de Pedidos"
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
    @html require("views/apps/procesos/pedidosAprobacion/layout")(PedidosAprobacion)
    @renderPedidos()
    PedidoPreparado.bind "query_success" , @renderPedidos
    PedidoPreparado.bind "push_success" , @renderPedidos

  reload: ->
    PedidoPreparado.query()    

  renderPedidos: =>
    @groups = PedidoPreparado.group_by_referencia()
    @log @groups
    @src_pedidos.html require("views/apps/procesos/pedidosAprobacion/item")(@groups)

  on_action_click: (e) =>
    target = $(e.target)
    referencia = target.attr "data-referencia"
    aprobar = parseInt(target.attr("data-aprobar"))
    group = null
    for g in @groups
      if g.Referencia == referencia
        group = g

    return false if !group
    @aprovedGroup = group if aprobar == 1
    @aprobar = aprobar
    Spine.trigger "show_lightbox" , "aprobarPedidos" , {group: group , aprobar: aprobar} , @aprobarSuccess

  aprobarSuccess: =>
    _kmq.push(['record', 'Aproved', {'Amount': @aprovedGroup.Total } ]) if @aprobar ==1
    @aprovedGroup = null
    @aprobar = null
    @renderPedidos()

  reset: ->
    PedidoPreparado.unbind "query_success" , @onLoadPedidos
    @release()
    @customReset?()
    @navigate "/apps"

module.exports = PedidosAprobacion