Spine = require('spine')
Producto = require("models/producto")

class listasPrecio extends Spine.Controller
  
  className: "row-fluid"
  
  @departamento = "Administracion"
  @label = "Lista de Precios"
  @icon = "icon-remove"

  elements:
    ".productList"       :  "productList"
    
  events:
    "click .btn_familia" : "onBtnFamilia"
    "click .cancel"      : "reset"
    "click .print"       : "onPrint"


  setVariables: ->

  setBindings: ->

  resetBindings: ->

  preset: ->
 
  constructor: ->
    super
    @setVariables()
    @preset()
    @render()
    @setBindings()
   
  render: ->
    @html require("views/apps/procesos/listasPrecio/layout")(app: listasPrecio , familias: Producto.groupByFamilia())

  onBtnFamilia: (e) =>
    familia = $(e.target).attr "data-familia"
    productos = Producto.findAllByAttribute("Familia" , familia )
    productos.sort (a,b) ->
      a.Grupo = 'N/D' if !a.Grupo
      b.Grupo = 'N/D' if !b.Grupo
      return if a.Grupo > b.Grupo then 1 else -1
    
    @productList.html require("views/apps/procesos/listasPrecio/item")(productos)

  onPrint: =>
    window.print()

  reset: () =>
    @resetBindings()
    @navigate "/apps"

module.exports = listasPrecio