Spine = require('spine')

Registro = require("models/registro")

class VerRegistros extends Spine.Controller
  
  className: "row-fluid verRegistros"
  
  @departamento = "Diario"
  @label = "Listado Registros"
  @icon = "icon-list"


  elements:
    ".registros_list"       :   "registros_list"
    ".departamentos_list"   :   "departamentos_list"
    ".viewDate"             :   "viewDate"
    ".totalVal"             :   "totalVal"
    
  events:
    "click .cancel" : "reset"
    "click .btn_departamento" : "onClickDepartamento"
    "click .doTotal"   : "onDoTotal"

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
      restData: { year: date.getFullYear() , month: date.getMonth() + 1 , day: date.getDate() , tipos: Registro.getAllowedDepartamentos()  }
      class: Registro

    Spine.trigger "show_lightbox" , "rest" , data  , @onRegistroLoaded

  render: ->
    @html require("views/apps/vistas/verRegistros/layout")(VerRegistros)
    pickers =  @el.find('.viewDate').datepicker({autoclose: true})
    #@viewDate.datepicker({autoclose: true})
    #pickers.on("change",@onInputChange)

  onRegistroLoaded: (success , results) =>
    #Hack to use REST to load Data for Free Edition Limits

    json  = JSON.stringify results
    Registro.refresh(json)
    
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
      items.addClass "hidden"
    else
      btn.addClass "active"
      items.removeClass "hidden"
  
  onDoTotal: =>
    items = @el.find("tr")
    total = 0
    for item in items
      item = $(item)
      if item.hasClass("hidden") == false
        it = item.find ".total"
        value = parseFloat( it.attr("data-monto") )
        console.log value
        total += value if value
    @totalVal.html total.toMoney()

  reset: ->
    Registro.destroyAll()
    @navigate "/apps"

module.exports = VerRegistros