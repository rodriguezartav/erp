Spine = require('spine')
Producto = require("models/producto")

class tomasInventario extends Spine.Controller
  
  className: "row-fluid"
  
  @departamento = "Inventarios"
  @label = "Toma Inventarios"
  @icon = "icon-edit"

  elements:
    ".productList"       :  "productList"
    
  events:
    "click .btn_familia" : "onBtnFamilia"
    "click .cancel"      : "reset"
    "click .print"       : "onPrint"
    "change input"       : "onInputChange"

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
    @html require("views/apps/procesos/tomasInventario/layout")(app: tomasInventario , familias: Producto.groupByFamilia())

  onBtnFamilia: (e) =>
    familia = $(e.target).attr "data-familia"
    productos = Producto.findAllByAttribute("Familia" , familia )
    productos.sort (a,b) ->
      a.Grupo = 'N/D' if !a.Grupo
      b.Grupo = 'N/D' if !b.Grupo
      return if a.Grupo > b.Grupo then 1 else -1
      
    @productList.html require("views/apps/procesos/tomasInventario/item")(productos)

  onPrint: =>
    window.print()
    
  onInputChange: (e) =>
    target= $(e.target)
    producto = Producto.find target.attr "data-producto"
    value = parseFloat target.val()
    parent = target.parents('tr')
    resultIcon = parent.find '.resultIcon'
    txtDiff = parent.find  ".txtDiff"

    resultIcon.removeClass()
    resultIcon.addClass "resultIcon"
    if producto.InventarioActual == value
      resultIcon.addClass "icon-ok"
    else
      resultIcon.addClass "icon-remove"
      
    txtDiff.html value - producto.InventarioActual
    
  reset: () =>
    @resetBindings()
    @navigate "/apps"

module.exports = tomasInventario