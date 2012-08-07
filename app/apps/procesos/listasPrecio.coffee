Spine = require('spine')
Producto = require("models/producto")

class listasPrecio extends Spine.Controller
  
  className: "row-fluid"
  
  @departamento = "Inventarios"
  @label = "Lista de Precios"
  @icon = "icon-table"

  elements:
    ".productList"       :  "productList"
    ".gruposList"        :  "gruposList"
    ".gruposList>li"     :  "gruposListElements"
    
  events:
    "click .btn_familia" : "onBtnFamilia"
    "click .btn_grupo"   : "onBtnGrupo"
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

  onBtnGrupo: (e) =>
    target = $(e.target)
    grupo = target.attr "data-grupo"
    target.parent().removeClass "active"
    
    $("tr[data-grupo='#{grupo}']").hide()
    

  onBtnFamilia: (e) =>
    familia = $(e.target).attr "data-familia"
    productos = Producto.findAllByAttribute("Familia" , familia )
    productos.sort (a,b) ->
      a.Grupo = 'N/D' if !a.Grupo
      b.Grupo = 'N/D' if !b.Grupo
      return if a.Grupo > b.Grupo then 1 else -1

    groups = []
    for producto in productos
      groups.push producto.Grupo if groups.indexOf(producto.Grupo) == -1
    
    @gruposList.html require("views/apps/procesos/listasPrecio/grupo")(groups)
    @productList.html require("views/apps/procesos/listasPrecio/item")(productos)

  onPrint: =>
    window.print()

  reset: () =>
    @resetBindings()
    @navigate "/apps"

module.exports = listasPrecio