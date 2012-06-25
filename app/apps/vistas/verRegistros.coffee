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
    ".viewDate"             : "viewDate"

    
  events:
    "click .cancel" : "reset"
    "click .btn_departamento" : "onClickDepartamento"

  setBindings: ->
    #Hack to use REST to load Data for Free Edition Limits
 
  preset: ->
    date = new Date()
    @reloadRegistros(date)
    
  constructor: ->
    super
    @preset()
    @render()
    @setBindings()
   
  reloadRegistros: (date) ->
    Registro.destroyAll()
    data=
      restRoute: "Registros"
      restMethod: "POST"
      restData: JSON.stringify( { year: date.getFullYear() , month: date.getMonth() + 1 , day: date.getDate()  } )
      class: Registro

    Spine.trigger "show_lightbox" , "rest" , data  , @onRegistroLoaded

  render: ->
    @html require("views/apps/vistas/verRegistros/layout")(VerRegistros)
    pickers =  @el.find('.viewDate').datepicker({autoclose: true})
    #@viewDate.datepicker({autoclose: true})
    #pickers.on("change",@onInputChange)

  onRegistroLoaded: (success , results) =>
    #Hack to use REST to load Data for Free Edition Limits
    
    Registro.refreshFromRest(results.results[0])
    
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