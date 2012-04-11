Spine = require('spine')
Producto = require("models/producto")

class Productos  extends Spine.Controller
  className: "search_productos"

  events: 
    "change input" : "on_filter"
    "click input" : "open"
    "click .productos_list>li>a" : "on_item_click"

  elements:
    ".productos_list" : "productos_list"
    ".productos_list>li" : "productos_list_items"
    ".js_search_productos" : "js_search_productos"
    "a.popable"           : "popovers"
    
  constructor: ->
    super
    @html require("views/productos/layout")(size: @size)
    @productos_list.hide() 

    Producto.bind "current_reset" , @productoSet
  
  productoSet: =>
    @js_search_productos.val ""
    @productos_list.empty()
    @productos_list.hide()

  render: (productos) =>
    @productos_list.html require("views/productos/list_item")(productos)
    @productos_list.show()
    $('a.popable').popover(placement: "bottom" , delay: { show: 150, hide: 100 })    

  hidePopOvers: =>
    $('a.popable').popover('hide')    

  open: (e) =>
    $(e.target).select()
    @productos_list.show()

  on_item_click: (e) =>
    t = $(e.target)
    parent = t.parents('li')
    id = parent.attr "data-id"
    producto = Producto.find(id)
    Producto.set_current producto
    @productos_list.hide()
    @hidePopOvers()
    
  on_filter: (e) =>
    return false if Producto.locked 
    @hidePopOvers()
    txt = $(e.target).val()
    result = Producto.filter txt
    @render result
    

  reset: =>
    Producto.unbind "current_reset" , @productoSet
    
    @release()
    

module.exports = Productos
