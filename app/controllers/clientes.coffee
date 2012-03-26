Spine = require('spine')
Cliente = require("models/cliente")

class Clientes  extends Spine.Controller
  className: "clientes"

  events: 
    "change .js_cliente_search" : "on_filter"
    "click .clientes_list>li>a" : "on_item_click"

  elements:
    ".clientes_list" : "clientes_list"
    ".clientes_list>li" : "clientes_list_items"
    ".js_cliente_search" : "js_cliente_search"

  constructor: ->
    super
    @html require("views/clientes/layout")
 
    Cliente.bind "current_reset" , =>
      @js_cliente_search.val ""
      
      
    @clientes_list.hide()

  render: (clientes) =>
    @clientes_list.html require("views/clientes/list_item")(clientes)
    @clientes_list.show()

  on_item_click: (e) =>
    t = $(e.target)
    parent = t.parent()
    id = parent.attr "data-id"
    cliente = Cliente.find(id)
    if Cliente.set_current cliente
      parent.toggleClass("active")
      parent.siblings().removeClass("active")
      @js_cliente_search.val cliente.Name
      @clientes_list.hide()
    
  on_filter: (e) =>
    return false if Cliente.locked 
    txt = $(e.target).val()
    result = Cliente.filter txt
    @render result

module.exports = Clientes
