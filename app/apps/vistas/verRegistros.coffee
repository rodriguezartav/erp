Spine = require('spine')

Registro = require("models/registro")

class VerRegistros extends Spine.Controller
  
  className: "row-fluid verRegistros"
  
  @departamento = "Vistas"
  @label = "Registros de Hoy"
  @icon = "icon-eye-open"


  elements:
    ".registros_list"       : "registros_list"
    ".departamentos_list"       : "departamentos_list"

    
  events:
    "click .cancel" : "reset"
    "click .btn_departamento" : "onClickDepartamento"

  setBindings: ->
    Registro.bind 'query_success' , @onRegistroLoaded
 
  preset: ->
    Registro.destroyAll()
    Registro.query()

  constructor: ->
    super
    @preset()
    @render()
    @setBindings()
   
  render: ->
    @html require("views/apps/vistas/verRegistros/layout")(VerRegistros)

  onRegistroLoaded: =>
    departamentos = Registro.uniqueDepartamentos()
    @departamentos_list.html require("views/apps/vistas/verRegistros/departamento")(departamentos)
    @registros_list.html require("views/apps/vistas/verRegistros/item")(Registro.all())
    
  onClickDepartamento: (e) =>
    target = $(e.target)
    grupo = target.attr "data-departamento"
    items = $("tr[data-departamento='#{grupo}']")
    btn = target.parent() 
    if btn.hasClass "active"
      btn.removeClass "active"
      items.hide()
    else
      btn.addClass "active"
      items.show()

  reset: ->
    Registro.destroyAll()
    @navigate "/apps"

module.exports = VerRegistros