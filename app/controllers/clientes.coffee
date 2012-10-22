Spine = require('spine')
Cliente = require("models/cliente")

class Clientes  extends Spine.Controller
  className: "clientes"

  events: 
    "change .js_cliente_search" : "on_filter"
    "click .clienteItem" : "onItemClick"
    "click .js_cliente_search" : "onCloseList"
    "click .showCreateContado" : "onShowCreateContado"
    "click .btn_select_credito" : "onCreditoSelect"
    "change .txt_data_contado"  : "onContadoChange"

  elements:
    ".clientes_list" : "clientes_list"
    ".clientes_list>li" : "clientes_list_items"
    ".js_cliente_search" : "js_cliente_search"
    ".mostrar_credito"  : "mostrar_credito"
    ".createContado" : "createContado"
    ".clientesPanel"   : "clientesPanel"
    ".txt_nombre"   : "txt_nombre"
    ".txt_cedula"   : "txt_cedula"
    ".hideable"   : "hideable"

  constructor: ->
    super
    @contado = false if !@contado
    @html require("views/controllers/clientes/layout")({contado: @contado})
    @js_cliente_search.val Cliente.find(@cliente).Name if @cliente
    @lock() if @cliente
    Cliente.bind "current_reset" , @clienteSet
    @clientes_list.hide()

  onCloseList: (e) =>
    target = $(e.target)
    target.select()
    if @clientes_list.css("display") != "none"
      @clientes_list.hide()      

  lock: =>
    @js_cliente_search.addClass "uneditable-input"
    @hideable.hide()

  clienteSet: =>
    @js_cliente_search.val ""

  render: (clientes) =>
    @clientes_list.html require("views/controllers/clientes/list_item")(clientes)
    @clientes_list.show()

  onItemClick: (e) =>
    t = $(e.target)
    parent = t
    until parent.attr "data-id"
      parent = t.parent(".clienteItem")
    id = parent.attr "data-id"
    cliente = Cliente.find(id)
    Cliente.set_current cliente
    console.log "Setting Current Cliente for Pagos"
    @trigger "credito_data_changed" , cliente
    parent.toggleClass("active")
    parent.siblings().removeClass("active")
    @js_cliente_search.val cliente.Name
    @clientes_list.hide()

  filterFunction: (query,item) =>
    return false if item.Activo == false
    return false if item.DiasCredito  > 0  and  @contado == true
    return false if item.DiasCredito == 0  and  @contado == false
    return false if !item.Name
    myRegExp =new RegExp( Cliente.queryToRegex(query),'gi')
    result = item.Name.search(myRegExp) > -1 or String(item.CodigoExterno).indexOf(query) == 0
    return result

  on_filter: (e) =>
    txt = $(e.target).val()
    result = Cliente.filter txt , @filterFunction
    @render result

  onShowCreateContado: =>
    @createContado.show()
    @clientesPanel.hide()
    @clientes_list.hide()
    @trigger "contado_data_changed"

  onContadoChange: =>
    @trigger "contado_data_changed" ,  { nombre: @txt_nombre.val() ,  cedula:   @txt_cedula.val() }

  onCreditoSelect: (e) =>
    target = $(e.target)
    @contado = target.attr "data-contado"    
    @clientes_list.hide()
    @clientes_list.empty()
    @js_cliente_search.val ""

  reset: =>
    Cliente.unbind "current_reset" , @clienteSet
    @release()

module.exports = Clientes
