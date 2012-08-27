Spine = require('spine')
Proveedor = require("models/proveedor")

class Proveedores  extends Spine.Controller
  className: "proveedores"

  events: 
    "change .js_proveedor_search" : "on_filter"
    "click .proveedores_list>li>a" : "on_item_click"

  elements:
    ".proveedores_list" : "proveedores_list"
    ".proveedores_list>li" : "proveedores_list_items"
    ".js_proveedor_search" : "js_proveedor_search"
    ".loader" : "loader"
    ".loadable" : "loadable"

  constructor: ->
    super
    @html require("views/controllers/proveedores/layout")
    Proveedor.reset()
    @loadable.show()
    @loader.hide()

    Proveedor.bind "current_reset" , =>
      @js_proveedor_search.val ""
      
    @loadable.hide() if Proveedor.count() == 0
    @proveedores_list.hide()

  setProveedor: =>
    @js_proveedor_search.val Proveedor.current.Name

  render: (proveedores) =>
    @proveedores_list.html require("views/controllers/proveedores/list_item")(proveedores)
    @proveedores_list.show()

  on_item_click: (e) =>
    t = $(e.target)
    parent = t.parent()
    id = parent.attr "data-id"
    proveedor = Proveedor.find(id)
    if Proveedor.set_current proveedor
      parent.toggleClass("active")
      parent.siblings().removeClass("active")
      @setProveedor()
      @proveedores_list.hide()
    
  on_filter: (e) =>
    return false if Proveedor.current
    return false if Proveedor.locked
    txt = $(e.target).val()
    result = Proveedor.filter txt
    @render result

  reset: =>
    Proveedor.unbind "query_success" , =>
      @loadable.show()
      @loader.hide()

    Proveedor.unbind "current_reset" , =>
      @js_proveedor_search.val ""
      
    @release()

module.exports = Proveedores
