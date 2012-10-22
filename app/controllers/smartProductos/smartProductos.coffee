Spine = require('spine')
Producto = require("models/producto")
PedidoItem = require("models/transitory/pedidoItem")
Negociacion = require("models/transitory/negociacion")


class SmartProductos  extends Spine.Controller
  className: "productos"

  events: 
    "change .js_producto_search" : "on_filter"
    "click .smartProductos_list>li" : "on_item_click"
    "change .txt_inventario" : "onInventarioInputClick"
    "click .btn_closeList" : "onCloseList"
    "click .btn_onHideEmpty" : "onHideEmpty"
    "click .categoriaItem" : "onCategoriaItemClick"
    "click .groupItem" : "onGroupItemClick"

  elements:
    ".smartProductos_list"     : "smartProductos_list"
    ".smartProductos_list>li"  : "smartProductos_listItems"
    ".smartItemsList"          : "smartItemsList"
    ".js_producto_search"      : "js_producto_search"
    ".categoriasList"          : "categoriasList"
    ".smartGroups_list"        : "smartGroups_list"
    ".categoriaLabel"          : "categoriaLabel"

  setBindings: =>
    Spine.bind "item_edit_started" , @onItemEdit
    Spine.bind "item_edit_ended" , @onItemView
    Spine.bind "item_deleted" , @onItemDeleted

  resetBindings: =>
    Spine.unbind "item_edit_start" , @onItemEdit
    Spine.unbind "item_edit_ended" , @onItemView
    Spine.unbind "item_deleted" , @onItemDeleted

  setVariables: =>
    @smartItemMap = {}
    @negociaciones = []

  constructor: () ->
    super
    throw "smartItem variable must be provided" if !@smartItem
    throw "referencia variable must be provided" if !@referencia
    @setVariables()
    @setBindings()
    @html require("views/controllers/smartProductos/layout")
    @renderCategorias()
    @smartProductos_list.hide()
    Producto.reset()
    
    Spine.s = @

  ###
  # render
  ###

  loadNegociaciones: (negociaciones) =>
    @negociaciones = negociaciones
    #for index,item in @smartItemMap
      #item.setNegociacion?(@negociaciones)

  render: (productos , renderGroups=true  ) =>
    @smartProductos_list.html require("views/controllers/smartProductos/listProducto")(productos)
    @smartProductos_list.show()

    return true if !renderGroups
    grupos = []
    for producto in productos
      grupos.push producto.Grupo if grupos.indexOf(producto.Grupo) == -1
    @smartGroups_list.html require("views/controllers/smartProductos/groupItem")(grupos)
    @smartGroups_list.show()

  renderCategorias: =>
    categorias= (producto.Categoria for producto in Producto.all() ).unique()
    categorias = categorias.sort (a,b) ->
      if a == 'Hilco' or a == "Candados" or a == "Cerraduras"
        return -1
      return 1
    @categoriasList.html require("views/controllers/smartProductos/categoriaItem")(categorias)

  ###
  # Filter
  ###

  on_filter: (e) =>
    return false if Producto.current
    txt = $(e.target).val()
    result = Producto.filter txt
    @render result
  
  onCategoriaItemClick: (e) =>
    target = $(e.target)
    categoria = target.attr "data-categoria"
    @categoriaLabel.html categoria
    productos = Producto.select (producto) =>
      return true if producto.Categoria == categoria
    @render @sortFunction productos

  onGroupItemClick: (e) =>
    target = $(e.target)
    @el.find(".groupItem").removeClass "active"
    target.addClass "active"
    grupo = target.attr "data-group"
    productos = Producto.select (producto) =>
      return true if producto.Grupo == grupo
    @render( @sortFunction(productos) , false )

  onItemDeleted: (productoId) =>
    delete @smartItemMap[productoId]
    @onItemView()
  
    ###
    # UX Utils
    ####

  onCloseList: =>
    @smartProductos_list.hide()
    @smartGroups_list.hide()
    @categoriaLabel.html "Categorias"

  onHideEmpty: (e) =>
    for hideable in @el.find ".hideable"
      hideable = $(hideable)
      inventario = hideable.attr("data-inventario")
      hideable.remove() if inventario == "0"

  onItemEdit:  =>
    @onCloseList()

  onItemView:  =>
    @smartProductos_list.show()
    @smartGroups_list.show()

  ###
  # Selection
  ###

  on_item_click: (e) =>
    @el.find(".smartProductos_list>li").removeClass "active"
    t = $(e.target)
    t = t.parent() until t.attr("data-id")
    t.addClass "active"
    t.find(".txt_inventario").focus()
    id = t.attr "data-id"
    producto = Producto.find(id)
    @addItem( producto , 1 )
    return false

  onInventarioInputClick: (e) => 
    target = $(e.target)
    t = $(e.target)
    t = t.parent() until t.attr("data-id")
    id = t.attr "data-id"
    producto = Producto.find(id)
    cantidad = parseFloat target.val()
    return false if !@addItem( producto , cantidad )
    
    target.val ""
    @smartProductos_list.find("li").removeClass "active"
    next = t.next()
    if next
      next.addClass "active"
      next.find(".txt_inventario").focus()
      @smartProductos_list.animate top: "+=48"
    return false;

  loadItem: (item) =>
    @smartItemMap[item.producto.id] = item
    @smartItemsList.append item.el

  addItem: (producto, cantidad) =>
    if @smartItemMap[producto.id]
      item = @smartItemMap[producto.id]
      item.updateCantidad(cantidad)
    else
     item = new @smartItem( producto: producto , cantidad:cantidad , referencia: @referencia )
     item.setNegociacion?(@negociaciones)
     if item.validateCreation()
       @smartItemMap[producto.id] = item
       @smartItemsList.append item.el
     else
      item.reset()

  onItemRemoved: (productoId) =>
    delete @smartItemMap[productoId]

  reset: =>
    Producto.unbind "query_success" , =>
      @loadable.show()
      @loader.hide()

    Producto.unbind "current_reset" , =>
      @js_producto_search.val ""
      
    @setVariables()
    @resetBindings()
    @release()

  sortFunction: (productos) =>
    productos.sort (a,b) ->
      res = 0
      return 0 if a.Name == b.Name
      return if a.Name < b.Name then -1 else 1
    return productos

module.exports = SmartProductos
