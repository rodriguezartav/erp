Spine = require('spine')
Producto = require("models/producto")

class Productos  extends Spine.Controller

  events: 
    "click .productoItem"   :  "on_item_click"
    "click .familiaItem"    :  "on_familia_click"
    "click .grupoItem"      :  "on_grupo_click"
    "click .minimize"       :  "close"
    "click .keepOpen"       :  "on_keepOpen_click"
    "click .hideEmpty"      :  "onHideEmpty"

  elements:
    ".badge"                :  "allFamiliasAndGroups"
    ".grupos_list"          :  "grupos_list"
    ".productos_list"       :  "productos_list"
    ".productos_list>li"    :  "productos_list_items"
    ".js_search_productos"  :  "js_search_productos"
    "a.popable"             :  "popovers"

  constructor: ->
    super
    @searchBox = $(".js_search_productos")
    @searchBox.change @on_filter
    @searchBox.click  @open
    @el.addClass "closed"
    Producto.bind "refresh" , @onFirstLoad

    #@productos_list.hide()
    Producto.bind "current_reset" , @productoSet

  onFirstLoad: =>
    Producto.unbind "refresh" , @onFirstLoad
    productos = Producto.select (item) ->
      return false if !item?.Categoria or item.Activo == false or item.Categoria == "Prueba"
      return true
    categorias= (producto.Categoria for producto in productos ).unique()
    categorias = categorias.sort (a,b) ->
      if a == 'Hilco' or a == "Candados" or a == "Cerraduras"
        return -1

      return 1
    @html require("views/controllers/productos/layout")(familias : categorias)

  productoSet: =>
    @js_search_productos.val ""
    @productos_list.empty()

  render: (productos, renderGroups = true) =>
    @open()
    grupos = []
    for producto in productos
      grupos.push producto.Grupo if grupos.indexOf(producto.Grupo) == -1

    @productos_list.html require("views/controllers/productos/producto")(productos)
    
    @grupos_list.html require("views/controllers/productos/grupo")(grupos) if renderGroups

  hidePopOvers: =>
    $('a.popable').popover('hide')    

  open: (e) =>
    @el.removeClass "closed"
    $("body").addClass "noScroll"
    

  close: (e) =>
    @el.addClass "closed"
    $("body").removeClass "noScroll"

  on_keepOpen_click: (e) =>
    target = $(e.target)
    if target.hasClass "active"
      target.removeClass "active" 
      @keepOpen = false
    else
      @keepOpen = true
      target.addClass "active" 


  onHideEmpty: (e) =>
    
    for hideable in @el.find ".hideable"
      hideable = $(hideable)
      inventario = hideable.attr("data-inventario")
      hideable.empty() if inventario == "0"
 

  on_item_click: (e) =>
    target = $(e.target)
    id = target.attr "data-id"
    producto = Producto.find(id)
    Producto.set_current producto
    @close() if !@keepOpen
    
  onPredefinedClick: (e) ->
    t = $(e.target)
    txt = t.attr "data-txt"
    @on_filter(false,txt)
    
  on_familia_click: (e) =>
    @allFamiliasAndGroups.removeClass "active"
    target = $(e.target)
    target.addClass "active"
    familia = target.attr "data-familia"
    productos = Producto.select (producto) =>
      return true if producto.Categoria == familia
    @render @sortFunction productos

  on_grupo_click: (e) =>
    @el.find(".grupoItem").removeClass "active"
    target = $(e.target)
    target.addClass "active"
    grupo = target.attr "data-grupo"
    productos = Producto.select (producto) =>
      return true if producto.Grupo == grupo
    @render( @sortFunction(productos) , false )

  on_filter: (e=fals,txt = false) =>
    return false if Producto.locked 
    @hidePopOvers()
    txt = $(e.target).val() if e
    result = Producto.filter txt
    @render @sortFunction result

  sortFunction: (productos) =>
    productos.sort (a,b) ->
      res = 0
      return 0 if a.Name == b.Name
      return if a.Name < b.Name then -1 else 1
    return productos
    

    
  filterFunction: (query,item) =>
    return false if item.Activo == false
    words = query.split(" ")
    for word in words
      return false if item.Name.indexOf(word) == -1
    
    return true




  reset: =>
    Producto.unbind "current_reset" , @productoSet
    @release()

module.exports = Productos
