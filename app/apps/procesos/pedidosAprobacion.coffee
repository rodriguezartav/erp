require('lib/setup')
Spine = require('spine')
Movimientos = require("controllers/movimientos")
Documento = require("models/documento")
Cliente = require("models/cliente")
Producto = require("models/producto")
Pedido = require("models/pedido")
Cuenta = require("models/cuenta")
User = require("models/user")

class PedidosAprobacion extends Spine.Controller
  className: "row"

  elements:
    ".error" : "error"
    ".src_pedidos" : "src_pedidos" 

  events:
    "click .cancel" : "cancel"
    "click .save" : "send"

  constructor: ->
    super
    @error.hide()
    Pedido.fetch_from_sf(User.current, { estado: pendiente } )
    Pedido.bind "ajax_complete" , @onLoadPedidos
    @render()

  render: =>  
    @html require("views/apps/procesos/pedidosAprobacion/layout")

  onLoadPedidos: =>
    @src_pedidos.html require("views/apps/procesos/pedidosAprobacion/item")(Pedido.group_by_referencia())

  cancel: ->
    @render()
    @onLoadPedidos()

  #####
  # ACTIONS
  #####

  send: (e) =>
    target = $(e.target)
    referencia = target.parents('li').attr "data-referencia"
    pedidos = Pedido.findAllByAttribute("Referencia", referencia)
    for pedido in pedidos
      pedido.estado = "Aprobado"
    Spine.trigger "show_lightbox" , "sendPedidos" , pedidos , @after_send

  after_send: =>
    @cancel()


module.exports = PedidosAprobacion