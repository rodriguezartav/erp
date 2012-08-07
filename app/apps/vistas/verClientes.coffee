Spine = require('spine')
Saldo = require("models/socketModels/saldo")
Cliente = require("models/cliente")

class VerClientes extends Spine.Controller
  
  className: "row-fluid verClientes"
  
  @departamento = "Pedidos"
  @label = "Ver Clientes"
  @icon = "icon-eye-open"

  
  elements:
    ".clientesList" : "clientesList"
  
  
  setBindings: ->
 
  preset: ->

  constructor: ->
    super
    @preset()
    @render()
    @setBindings()
   
  render: ->
    @html require("views/apps/vistas/verClientes/layout")(VerClientes)
    
    clientes = Cliente.all()
    clientes = clientes.sort (a,b) ->
      return parseInt(a.CodigoExterno) - parseInt(b.CodigoExterno)
    
    @clientesList.html require("views/apps/vistas/verClientes/item")(clientes)

  reset: ->
    @navigate "/apps"

module.exports = VerClientes