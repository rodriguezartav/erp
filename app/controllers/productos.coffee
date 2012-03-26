Spine = require('spine')
Producto = require("models/producto")

class Productos  extends Spine.Controller
  className: "productos"

  events: 
    "change input" : "on_filter"
    "click .productos_list>li>a" : "on_item_click"

  elements:
    ".productos_list" : "productos_list"
    ".productos_list>li" : "productos_list_items"
    ".js_search_productos" : "js_search_productos"
    
  constructor: ->
    super
  
    @html require("views/productos/layout")(size: @size)
    @productos_list.hide() 
    
   
    Producto.bind "current_reset" , =>
      @js_search_productos.val ""
      @productos_list.empty()
      @productos_list.hide()

  render: (productos) =>
    @productos_list.html require("views/productos/list_item")(productos)
    @productos_list.show()
    

  on_item_click: (e) =>
    t = $(e.target)
    parent = t.parent()
    id = parent.attr "data-id"
    producto = Producto.find(id)
    Producto.set_current producto
      
    
  on_filter: (e) =>
    return false if Producto.locked 
    txt = $(e.target).val()
    result = Producto.filter txt
    @render result

module.exports = Productos
