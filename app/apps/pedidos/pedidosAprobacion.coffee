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
    PedidoPreparado.bind "push_success" , @renderPedidos

  reload: ->
    PedidoPreparado.ajax().query( { especial: false }   , afterSuccess: @renderPedidos)    

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
    
    ids = []
    ids.push pedido.id for pedido in group.Pedidos

    data =
      class: PedidoPreparado
      restRoute: "Oportunidad"
      restMethod: "PUT"
      restData: ids: ids , observacion: "" , aprobar: aprobar

    Spine.trigger "show_lightbox" , "rest" , data , @aprobarSuccess

  aprobarSuccess: =>
    @notify()
    for pedido in @aprovedGroup.Pedidos
      pedido.destroy()
    @aprovedGroup = null
    @aprobar = null
    @renderPedidos()

  notify: =>
    cliente = Cliente.find @aprovedGroup.Cliente
    verb = if @aprobar == 1 then "Aprobe" else "Archive"
    Spine.socketManager.pushToFeed("#{verb} un pedido de #{cliente.Name}") 

    Spine.throttle ->
      Spine.socketManager.pushToProfile("Ejecutivo Ventas" , "#{verb} varios pedidos, pueden proceder a revisarlos.")
    , 15000

  reset: ->
    PedidoPreparado.unbind "push_success" , @renderPedidos
    @el.find('.popable').popover("hide")
    @release()
    @navigate "/apps"

module.exports = PedidosAprobacion