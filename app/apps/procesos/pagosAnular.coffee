Spine = require('spine')
Cliente = require("models/cliente")
Clientes = require("controllers/clientes")
Pago = require("models/pago")

class PagosAnular extends Spine.Controller
  
  className: "row-fluid"
  
  @departamento = "Credito y Cobro"
  @label = "Anular Pagos"
  @icon = "icon-remove"


  elements:
    ".src_cliente"       :  "src_cliente"
    ".js_create_pago"    :  "btn_create_pago"
    ".src_pagos"       : "src_pagos"
    
  events:
    "click .cancel" : "reset"
    "click .anular" : "anular"

  setVariables: ->

  setBindings: ->
    Pago.bind 'query_success' , @onPagoLoaded
    Cliente.bind 'current_set' , @onClienteSet

  resetBindings: ->
    Pago.unbind 'query_success' , @onPagoLoaded
    Cliente.unbind 'current_set' , @onClienteSet

  preset: ->
    Cliente.reset()
    Pago.destroyAll()
 
  constructor: ->
    super
    @setVariables()
    @preset()
    @render()
    @setBindings()
   
  render: ->
    @html require("views/apps/procesos/pagosAnular/layout")(PagosAnular)
    new Clientes(el: @src_cliente)

  onClienteSet: (cliente) =>
    Pago.destroyAll()
    Pago.query({ cliente: cliente ,fecha: "THIS_MONTH" })
    
  onPagoLoaded: =>
    @src_pagos.html require("views/apps/procesos/pagosAnular/item")(Pago.group_by_recibo())
    
  anular: (e) ->
    target = $(e.target)
    reciboId = target.attr "data-recibo"

    data =
      class: Pago
      restRoute: "Anular"
      restMethod: "POST"
      restData: JSON.stringify( { id: reciboId , tipo: "Pago" } )

    Spine.trigger "show_lightbox" , "rest" , data , @reset
 
    
  reset: () =>
    @resetBindings()
    Pago.destroyAll()
    @navigate "/apps"

module.exports = PagosAnular