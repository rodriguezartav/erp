Spine = require('spine')
Cliente = require("models/cliente")

class Clientes  extends Spine.Controller
  className: "clientes"

  events: 
    "change .js_cliente_search" : "on_filter"
    "click .clientes_list>li>a" : "on_item_click"
    "click .select_contado" : "onSelectContadoClick"
    "click .mostrar_credito"  : "onMostrarCredito"
    "click .js_cliente_search" : "onCloseList"
    
    
  elements:
    ".clientes_list" : "clientes_list"
    ".clientes_list>li" : "clientes_list_items"
    ".js_cliente_search" : "js_cliente_search"
    ".mostrar_credito"  : "mostrar_credito"

  constructor: ->
    super
    @contado = false if @contado ==null
    
    @html require("views/clientes/layout")({contado: @contado})
 
    @js_cliente_search.val Cliente.find(@cliente).Name if @cliente
 
    Cliente.bind "current_reset" , @clienteSet
      
    @clientes_list.hide()

  onCloseList: =>
    if @clientes_list.css("display") != "none"
      @clientes_list.hide()      

  onMostrarCredito: =>
    @contado = false
    @mostrar_credito.hide()

  clienteSet: =>
    @js_cliente_search.val ""

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

  filterFunction: (query,item) =>
    return false if item.Activo == false
    return false if item.DiasCredito > 0 and @contado == true
    return false if item.DiasCredito == 0 and @contado == false
    myRegExp =new RegExp( Cliente.queryToRegex(query),'gi')
    item.Name.search(myRegExp) > -1 or String(item.CodigoExterno).indexOf(query) == 0


  on_filter: (e) =>
    return false if Cliente.locked 
    txt = $(e.target).val()
    result = Cliente.filter txt,@filterFunction
    @render result

  reset: =>
    Cliente.unbind "current_reset" , @clienteSet
    @release()

module.exports = Clientes
