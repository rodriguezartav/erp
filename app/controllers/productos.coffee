require('lib/setup')
Spine = require('spine')
Producto = require("models/producto")

class Productos  extends Spine.Controller
  className: "productos columns three"

  events: 
    "change input" : "on_filter"
    "click .productos_list>li>a" : "on_item_click"

  elements:
    ".productos_list" : "productos_list"
    ".productos_list>li" : "productos_list_items"

  constructor: ->
    super
    Producto.bind "refresh" , @on_producto_refresh
    Producto.bind "current_reset" , @on_producto_refresh
    @html require("views/productos/layout")

  on_producto_refresh: (productos = null) =>
    productos = Producto.all() if !productos
    @productos_list.html require("views/productos/list_item")(productos)

  on_item_click: (e) =>
    t = $(e.target)
    parent = t.parent()
    id = parent.attr "data-id"
    producto = Producto.find(id)
    if Producto.set_current producto
      parent.toggleClass("active")
      parent.siblings().removeClass("active")
    
  on_filter: (e) =>
    return false if Producto.locked 
    txt = $(e.target).val()
    result = Producto.filter txt
    @on_producto_refresh result

module.exports = Productos
