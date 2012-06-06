require('lib/setup')
Spine = require('spine')
Documento = require("models/documento")
Cliente = require("models/cliente")


class AjustarCredito extends Spine.Controller
  @departamento = "Credito y Cobro"
  @label = "Ajustar Credito"
  @icon = "icon-ok"

  className: "row-fluid"

  events:
    "click .cancel" : "reset"
    "change .txtFilter"  : "onSearch"
    "change .txtSlider" : "onAdjust"
    "click .aprobar"    : "onAprobar"

  elements: 
    ".saldosList" : "list"

  constructor: ->
    super
    @html require("views/apps/procesos/ajustarCredito/layout")(@constructor)
    @render( Cliente.all() )

  render: (clientes) =>
    @list.html require("views/apps/procesos/ajustarCredito/item")(clientes)

  filterFunction: (query,item) =>
    return false if item.Activo == false
    return false if item.DiasCredito > 0
    myRegExp =new RegExp( Cliente.queryToRegex(query),'gi')
    item.Name.search(myRegExp) > -1 or String(item.CodigoExterno).indexOf(query) == 0

  onSearch: (e) =>
    return false if Cliente.locked 
    txt = $(e.target).val()
    result = Cliente.filter txt,@filterFunction
    @render result

  onAdjust: (e) =>
    slider = $(e.target)
    val = slider.val()
    id = slider.attr "data-cliente"
    cliente = Cliente.find id
    slider.attr "data-changed" , "true"
    slider.parents('tr').find(".txtNewCredito").html parseFloat(val).toMoney()

  onAprobar: (e) =>
    btn = $(e.target)
    id = btn.attr "data-cliente"
    val = btn.parents('tr').find(".txtSlider").val()
    cliente = Cliente.find id
    cliente.CreditoAsignado = val;
    cliente.save()

    clienteSf = Cliente.toSalesforce(cliente)

    data =
      class: Cliente
      restRoute: "Cliente"
      restMethod: "PUT"
      restData: JSON.stringify({ cliente: clienteSf })
      
    Spine.trigger "show_lightbox" , "rest" , data , @after_send
 
  after_send: ->
  
 
  reset: =>
    @release()
    @navigate "/apps"

module.exports = AjustarCredito