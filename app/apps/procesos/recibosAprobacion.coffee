require('lib/setup')
Spine = require('spine')
Recibo = require("models/recibo")
User = require("models/user")

class RecibosAprobacion extends Spine.Controller
  className: "row"

  @departamento = "Tesoreria"
  @label = "Aprobacion de Recibos"

  elements:
    ".error" : "error"
    ".src_recibos" : "src_recibos" 
    ".content" : "content"

  events:
    "click .cancel"   : "reset"
    "click .aprobar"  : "on_action_click"
    "click .reload" : "reload"

  constructor: ->
    super
    @error.hide()
    @html require("views/apps/procesos/recibosAprobacion/layout")(RecibosAprobacion)
    Recibo.query({})
    Recibo.bind "query_success" , @renderRecibos

  renderRecibos: =>
    @src_recibos.html require("views/apps/procesos/recibosAprobacion/item")(Recibo.all())

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
    Pedido.unbind "query_success" , @onLoadPedidos
    @release()
    @customReset?()
    @navigate "/apps"

module.exports = RecibosAprobacion