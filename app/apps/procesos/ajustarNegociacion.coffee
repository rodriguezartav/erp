require('lib/setup')
Spine = require('spine')
Producto = require("models/producto")
Cliente = require("models/cliente")
Negociacion = require("models/transitory/negociacion")
Clientes = require("controllers/clientes")

class Items extends Spine.Controller
  @extend Spine.Controller.ViewDelegation
  
  tag: "tr"

  elements:
    ".validatable" : "inputs_to_validate"

  events:
    "click .js_btn_remove" : "reset"
    "change input" : "checkItem"
    "click input" : "on_click"

  constructor: ->
    super 
    @negociacion = Negociacion.createFromProducto(@producto) if @producto
    @html require("views/apps/procesos/ajustarNegociacion/item")(@negociacion) 

  on_click: (e) =>
    $(e).select()

  checkItem: (e) =>
    @updateFromView(@negociacion,@inputs_to_validate)

  reset: =>
    @negociacion.destroy()
    @release()

class AjustarNegociacion extends Spine.Controller
  
  className: "row-fluid"

  @departamento = "Pedidos"
  @label = "Negocios Especiales"
  @icon = "icon-key"

  elements:
    ".items_list" : "items_list"
    ".src_cliente" : "src_cliente"
    ".src_negociacion" : "items_list"
    ".validatable" : "inputs_to_validate"
    ".lbl_subTotal" : "lbl_subTotal"
    ".lbl_descuento" : "lbl_descuento"
    ".lbl_impuesto" : "lbl_impuesto"
    ".lbl_total" : "lbl_total"
    ".clientes_list" : "clientes_list"
    ".lbl_cliente"   : "lbl_cliente"
    ".itemsSubFamilias" : "itemsSubFamilias"
    ".itemsFamilias" : "itemsFamilias"
    ".srcSubfamilias" : "srcSubfamilias"

  events:
    "click .cancel" : "reset"
    "click .save" : "send"
    "click .clienteItem>a" : "onClienteItemClick"
    "click .btn_agregarNegociacion" : "onAddNegociacion"
    "click .src_cliente" : "onClientesClick"
    "click .itemFamilia" : "onItemFamiliaClick"
    "click .itemSubFamilia" : "onItemSubFamiliaClick"

  constructor: ->
    super
    Producto.reset()
    Cliente.reset()

    @items = []
    @itemToControllerMap ={}
    
    @html require("views/apps/procesos/ajustarNegociacion/layout")(@)
    @clientes = new Clientes(el: @src_cliente)
    @setBindings()
    @addClientesWithNegociacion()

  setBindings: =>
    Producto.bind "current_set" , @addItem
    Cliente.bind "current_set" , @addCliente
  
  resetBindings: =>
    Cliente.unbind "current_set" , @addCliente
    Producto.unbind "current_set" , @addItem

  addClientesWithNegociacion: =>
    clientes = Cliente.select (cliente) ->
      return if cliente.Negociacion?.length > 0 then true else false
    @clientes_list.html require("views/apps/procesos/ajustarNegociacion/clienteItem")(clientes)
    
  onClienteItemClick: (e) ->
    target = $(e.target).parents(".clienteItem")
    id = target.attr "data-id"
    cliente = Cliente.find id 
    Cliente.set_current cliente
    @addItems()
    
  addCliente: =>
    Negociacion.destroyAll()
    @addItems()

  onAddNegociacion: =>
    return false if !Cliente.current
    @addItem("0","0")

  addItems: =>
    for item in @items
      item.reset()
   
    @lbl_cliente.html "<a>#{Cliente.current.Name}</a>"
    Negociacion.createFromCliente(Cliente.current)

    for negociacion in Negociacion.all()
      item = new Items(negociacion: negociacion )
      @items.push item
      @itemToControllerMap[item.negociacion.id] = item
      @items_list.append item.el
      @onNegociacionChange()
  
  addItem: (familia,subfamilia) =>
    negociacion1 = Negociacion.findAllByAttribute( "SubFamilia" , Producto.SubFamilia )
    negociacion2 = Negociacion.findAllByAttribute( "Familia" , Producto.Familia )
    return false if negociacion1.length > 0 and negociacion2.length > 0
    return false if !Cliente.current
    negociacion = new Negociacion Familia: familia ,  SubFamilia: subfamilia , Descuento: 0 
    
    item = new Items(negociacion: negociacion)
    @items.push item
    @itemToControllerMap[item.negociacion.id] = item
    @items_list.append item.el
    @onNegociacionChange()
    $('a.popable').popover(placement: "bottom")    

  removeItem: (item) =>
    item = @itemToControllerMap[item.id]
    index = @items.indexOf(item)
    @items.splice(index,1)
    @itemToControllerMap[item.id] = null

  onNegociacionChange: =>
    #@pedido.updateFromPedidoItems(PedidoItem.all())
    #@pedido.save()
    
  customValidation: =>
    @validationErrors.push "Ingrese el Nombre del Cliente" if Cliente.current == null
    @validationErrors.push "Ingrese al menos un Producto" if Negociacion.count() == 0
    item.checkItem() for item in @items
    
  
  onItemFamiliaClick: (e) =>
    @itemsFamilias.removeClass "active"
    target = $(e.target)
    target.parents("li").addClass "active"
    familia = target.data("familia")
    familia = familia.substring(0, familia.length - 1)
    subs = Producto.getSubFamilias(familia)
    @srcSubfamilias.html require("views/apps/procesos/ajustarNegociacion/itemSubFamilia")(subs)
  
  onItemSubFamiliaClick: (e) =>
    target = $(e.target)
    subfamilia = target.data "subfamilia"
    familia = $("li.itemsFamilias.active").find(".itemFamilia").data "familia"
    familia = familia.substring(0, familia.length - 1)
    @addItem(familia,subfamilia)
    
    return false;
  
  onClientesClick: (e) =>
    return false
  
  send: (e) =>
    Cliente.current.Negociacion =  JSON.stringify Negociacion.all()
    Cliente.current.save()

  after_send: =>
    Spine.socketManager.pushToFeed("He ingresado nueva negociaciones fijas.")
    @reset()

  reset: =>
    @clientes.reset()
    for items in @items
      items?.reset()
    Producto.reset()
    Cliente.reset()
    @resetBindings()
    Negociacion.destroyAll()
    @navigate "/apps"
    
  
module.exports = AjustarNegociacion