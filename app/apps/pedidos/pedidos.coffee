require('lib/setup')
Spine = require('spine')
Producto = require("models/producto")
Cliente = require("models/cliente")
Negociacion = require("models/transitory/negociacion")
Pedido = require("models/transitory/pedido")
PedidoItem = require("models/transitory/pedidoItem")
Clientes = require("controllers/clientes")
SinglePedido = require("apps/pedidos/singlePedidos")    
    
class Pedidos extends Spine.Controller
  className: "row-fluid listable pedidos"

  @departamento = "Pedidos"
  @label = "Digitar Pedidos"
  @icon = "icon-shopping-cart"

  elements:
    ".list_item" : "list_item"

  events:
    "click .pedido"    : "onPedidoClick"
    "click .btn_createPedido" : "onCreatePedido"

  setVariables: =>
    @pedidos = Pedido.all()
    @currentController = null
    @pedidoControllers = []
    @pedidoToControllerMap = {}

  setBindings: =>
    Pedido.bind "beforeDestroy" , @onPedidoDestroy

  resetBindings: =>
    Pedido.unbind "beforeDestroy" , @onPedidoDestroy

  constructor: ->
    super
    @setVariables()
    @html require("views/apps/pedidos/pedidos/layout")(Pedidos)
    @setBindings()
    @loadPedido()

  loadPedido: =>
    for pedido in @pedidos
      singlePedido = @createPedido(pedido)
      @setCurrentController(singlePedido)

  onCreatePedido: =>
    singlePedido = new SinglePedido()
    @pedidoToControllerMap[singlePedido.pedido.Referencia] = singlePedido
    @append singlePedido
    singlePedido

  createPedido: (pedido=null) =>
    singlePedido = new SinglePedido(pedido: pedido)
    @pedidoToControllerMap[singlePedido.pedido.Referencia] = singlePedido
    @append singlePedido
    @setCurrentController(singlePedido)
    singlePedido

  onPedidoClick: (e) =>
    pedidoEl = $(e.target).parents(".pedido")
    referencia = pedidoEl.attr("data-referencia")
    singlePedido = @pedidoToControllerMap[referencia]
    @setCurrentController(singlePedido)
    return true;

  setCurrentController: (controller) =>
    @list_item.removeClass "active"
    @currentController = null
    if controller
      @currentController = controller
      @currentController.el.addClass "active"

  onPedidoDestroy: (pedido) =>
    delete @pedidoToControllerMap[pedido.Referencia]
    @setCurrentController(null);

  reset: =>
    @resetBindings()
    for index,controller of @pedidoToControllerMap
      controller.lightReset() if controller
    @setVariables()
    @release()
    @navigate "/apps"
  
module.exports = Pedidos