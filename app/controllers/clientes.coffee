require('lib/setup')
Spine = require('spine')
Cliente = require("models/cliente")

class Clientes  extends Spine.Controller
  className: "clientes columns three"

  events: 
    "change input" : "on_filter"
    "click .clientes_list>li>a" : "on_item_click"

  elements:
    ".clientes_list" : "clientes_list"
    ".clientes_list>li" : "clientes_list_items"
    ".js_cliente_search" : "txt_cliente_name"

  constructor: ->
    super
    Cliente.bind "refresh" , @on_cliente_refresh
    Cliente.bind "current_reset" , @on_cliente_refresh
    @html require("views/clientes/layout")

  on_item_click: (e) =>
    t = $(e.target)
    parent = t.parent()
    id = parent.attr "data-id"
    cliente = Cliente.find(id)
    if Cliente.set_current cliente
      parent.toggleClass("active")
      parent.siblings().removeClass("active")
    
  on_filter: (e) =>
    return false if Cliente.locked 
    txt = $(e.target).val()
    result = Cliente.filter txt
    @on_cliente_refresh result

module.exports = Clientes
