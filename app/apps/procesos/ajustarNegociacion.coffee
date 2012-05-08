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
    @log @negociacion
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

  @departamento = "Ventas"
  @label = "Negociaciones"
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

  events:
    "click .cancel" : "reset"
    "click .save" : "send"

  constructor: ->
    super
    Producto.reset()
    Cliente.reset()

    @items = []
    @itemToControllerMap ={}
    
    @html require("views/apps/procesos/ajustarNegociacion/layout")(@)
    @clientes = new Clientes(el: @src_cliente)

    @setBindings()

  setBindings: =>
    Producto.bind "current_set" , @addItem
    Cliente.bind "current_set" , @addCliente
  
  resetBindings: =>
    Cliente.unbind "current_set" , @addCliente
    Producto.unbind "current_set" , @addMovimiento
    
  addCliente: =>
    Cliente.current.locked = true
    @log Cliente.current
    @addItems()

  addItems: =>
    for item in @items
      item.reset()
   
    Negociacion.createFromCliente(Cliente.current)
    
    for negociacion in Negociacion.all()
      item = new Items(negociacion: negociacion )
      @items.push item
      @itemToControllerMap[item.negociacion.id] = item
      @items_list.append item.el
      @onNegociacionChange()
  
  addItem: =>
    negociacion1 = Negociacion.findAllByAttribute( "SubFamilia" , Producto.SubFamilia )
    negociacion2 = Negociacion.findAllByAttribute( "Familia" , Producto.Familia )
    return false if negociacion1.length > 0 and negociacion2.length > 0
    return false if !Cliente.current
    item = new Items(producto: Producto.current)
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
    
  send: (e) =>
    Cliente.current.Negociacion =  JSON.stringify Negociacion.all() 
    Cliente.current.save()
    data =
      class: Cliente
      restRoute: "Cliente"
      restMethod: "PUT"
      restData: JSON.stringify({ cliente: Cliente.toSalesforce(Cliente.current) })
      
    Spine.trigger "show_lightbox" , "update" , data , @after_send   

  after_send: =>
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