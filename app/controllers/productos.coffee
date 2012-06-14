Spine = require('spine')
Producto = require("models/producto")

class Productos  extends Spine.Controller

  events: 
    "change .js_search_productos" : "on_filter"
    "click .js_search_productos" : "open"
    "click .thumbnail" : "on_item_click"
    "click a.predefined" : "onPredefinedClick"


  elements:
    ".productos_list" : "productos_list"
    ".productos_list>li" : "productos_list_items"
    ".js_search_productos" : "js_search_productos"
    "a.popable"           : "popovers"

  constructor: ->
    super
    @productos_list.hide()
    Producto.bind "current_reset" , @productoSet

  productoSet: =>
    @js_search_productos.val ""
    @productos_list.empty()
    @productos_list.hide()

  render: (productos) =>
    @productos_list.html require("views/controllers/productos/list_item")(productos)
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
    
  onPredefinedClick: (e) ->
    t = $(e.target)
    txt = t.attr "data-txt"
    @on_filter(false,txt)
    
  on_filter: (e=false,txt = false) =>    
    return false if Producto.locked 
    @hidePopOvers()
    txt = $(e.target).val() if e
    result = Producto.filter txt
    @render result

  reset: =>
    Producto.unbind "current_reset" , @productoSet
    @release()

module.exports = Productos
