require('lib/setup')
Spine = require('spine')
Producto = require("models/producto")
Cliente = require("models/cliente")
Negociacion = require("models/transitory/negociacion")
Pedido = require("models/transitory/pedido")
PedidoItem = require("models/transitory/pedidoItem")
Clientes = require("controllers/clientes")
SmartProductos = require("controllers/smartProductos/smartProductos")
SmartItemPedido = require("controllers/smartProductos/smartItemPedido")

class SinglePedidos extends Spine.Controller
  @extend Spine.Controller.ViewDelegation
  
  className: "row-fluid pedido list_item active"

  @departamento = "Pedidos"
  @label = "Digitar Pedido"
  @icon = "icon-shopping-cart"

  elements:
    ".alert_box" : "alert_box"
    ".src_cliente" : "src_cliente"
    ".src_smartProductos" : "src_smartProductos"
    ".lbl_subTotal" : "lbl_subTotal"
    ".lbl_descuento" : "lbl_descuento"
    ".lbl_impuesto" : "lbl_impuesto"
    ".lbl_total" : "lbl_total"
    ".lbl_PedidoTipo" : "lbl_PedidoTipo"
    ".validatable" : "inputs_to_validate"

  events:
    "click .cancel" : "onRemove"
    "click .save" : "send"
    "click .lbl_PedidoTipo" : "onTipoPedidoClick"

  setVariables: =>
    Negociacion.destroyAll()
    @negociaciones = []
    @pedidoItems = [] if !@pedidoItems

  setBindings: =>
    PedidoItem.bind "update"          , @onPedidoItemChange
    PedidoItem.bind "destroy"          , @onPedidoItemChange
    @clientes.bind "credito_data_changed"    , @addCliente
    @clientes.bind "contado_data_changed"    , @onContadoMode

  resetBindings: =>
    PedidoItem.unbind "update"        , @onPedidoItemChange
    PedidoItem.unbind "destroy"          , @onPedidoItemChange
    @clientes.unbind "credito_data_changed"  , @addCliente
    @clientes.unbind "contado_data_changed"  , @onContadoMode

  constructor: ->
    super
    @pedidoItems = PedidoItem.itemsInPedido(@pedido) if @pedido
    referencia = Spine.session.getConsecutivoPedido()

    @pedido = Pedido.create( { Referencia: referencia , Tipo_de_Documento: "FA" , IsContado: false , Especial: false }) if !@pedido
    @html require("views/apps/pedidos/pedido/layout")(Pedido)
    @el.attr "data-referencia" , @pedido.Referencia
    @setVariables()
    @clientes = new Clientes(el: @src_cliente , cliente: @pedido.Cliente )
    @smartProductos = new SmartProductos( el: @src_smartProductos , smartItem: SmartItemPedido , referencia: @pedido.Referencia )
    @setBindings()
    @negociaciones = Negociacion.createFromCliente(Cliente.find @pedido.Cliente) if @pedido.Cliente
    for pedidoItem in @pedidoItems
      smartItem = new SmartItemPedido(dataItem: pedidoItem, producto: Producto.find(pedidoItem.Producto) )
      smartItem.setNegociacion(@negociaciones)
      @smartProductos.loadItem(smartItem)
    @pedidoItemChanged()

  addCliente: (cliente) =>
    return false if !@el.hasClass "active"
    @pedido.Cliente = cliente.id
    if cliente.DiasCredito == 0
      @pedido.IsContado = true
      @lbl_PedidoTipo.html "Contado"
    @pedido.save()
    @clientes.lock()
    Negociacion.destroyAll()
    @negociaciones = Negociacion.createFromCliente(cliente)
    @smartProductos.loadNegociaciones(@negociaciones)

  onPedidoItemChange: (e) =>
    clearTimeout(@throttleTimer) if @throttleTimer
    @throttleTimer = setTimeout =>
      @pedidoItemChanged.apply(@, arguments);
    , 300


  pedidoItemChanged: =>
    items = PedidoItem.itemsInPedido(@pedido)
    @pedido.updateFromPedidoItems(items)
    @lbl_subTotal.html @pedido.SubTotal.toMoney()
    @lbl_descuento.html @pedido.Descuento.toMoney()
    @lbl_impuesto.html @pedido.Impuesto.toMoney()
    @lbl_total.html @pedido.Total.toMoney()
    @pedido.Especial = false
    for item in items
      if item.Especial
        @pedido.Especial = true
        @lbl_PedidoTipo.html "Especial"
    @pedido.save()

  customValidation: =>
    movimientos = PedidoItem.itemsInPedido(@pedido)
    @validationErrors.push "Ingrese el Nombre del Cliente" if @pedido.Cliente == null and !@pedido.IsContado
    @validationErrors.push "Ingrese los detalles del Cliente" if @pedido.IsContado and !@pedido.Cliente and ( !@pedido.Nombre or !@pedido.Identificacion )
    @validationErrors.push "Ingrese al menos un producto" if movimientos.length == 0
    @checkItem(item) for item in movimientos

  checkItem: (dataItem) =>
    dataItem.updateSubTotal()
    dataItem.applyDescuento()
    dataItem.applyImpuesto()
    dataItem.updateTotal()

  onContadoMode: (data={}) =>
    @pedido.IsContado=true;
    @pedido.Nombre = data.nombre if data.nombre
    @pedido.Identificacion = data.cedula if data.cedula
    @pedido.save()
    @lbl_PedidoTipo.html "Contado"

  onTipoPedidoClick: (e) =>
    target = $(e.target)
    if target.html() == "Credito"
      target.html("Contado")
      @pedido.IsContado=true;
      @pedido.save()      

  beforeSend: (object) ->
    nombre = @el.find('.nombre').val()
    for pi in PedidoItem.itemsInPedido(object)
      pi.Cliente = object.Cliente if object.Cliente
      pi.Referencia = object.Referencia
      pi.Orden = object.Orden
      pi.Fuente = Spine.options.locationType
      pi.Observacion = object.Observacion
      pi.IsContado = object.IsContado
      pi.Transporte = object.Transporte
      pi.Especial = object.Especial || false
      pi.Estado = "Pendiente"
      if object.IsContado
        pi.Nombre = object.Nombre
        pi.Identificacion = object.Identificacion
      pi.save()

  send: (e) =>
    target = $(e.target)
    @updateFromView(@pedido,@inputs_to_validate)
    @pedido.save()
    @after_send()
    #pedidos = PedidoItem.salesforceFormat( PedidoItem.itemsInPedido(@pedido)  , false) 

    #data =
      #class: PedidoItem
      #restRoute: "Oportunidad"
      #restMethod: "POST"
      #restData: oportunidades: pedidos 

    #console.log data
    #Spine.trigger "show_lightbox" , "rest" , data , @after_send

  after_send: =>
    @notify()
    @onSuccess?()
    @reset()

  notify: () =>
    try
      return false if @pedido.IsContado
      cliente = Cliente.find @pedido.Cliente
      Spine.socketManager.pushToFeed "Ingrese un Pedido de #{cliente.Name}"
    catch error
      console.log error

  onRemove: =>
    @resetBindings()
    PedidoItem.deleteItemsInPedido(@pedido)
    @pedido.destroy()
    @onCancel?()
    @reset()

  lightReset: =>
    @resetBindings()
    @smartProductos.reset()
    @clientes.reset()
    @pedidoItem = []
    @setVariables()
    @release()

  reset: =>
    #@pedido.destroy()
    @resetBindings()
    @smartProductos.reset()
    @clientes.reset()
    @pedidoItem = []
    @setVariables()
    @release()
  
module.exports = SinglePedidos