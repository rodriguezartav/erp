Spine = require('spine')
Registro = require("models/registro")

class VerRegistrosResumen extends Spine.Controller
  
  className: "row-fluid VerRegistroResumen"
  
  @departamento = "Diario"
  @label = "Registos Resumen"
  @icon = "icon-th"

  elements:
    ".departamentos_list"       : "departamentos_list"
    ".viewDate"             : "viewDate"

  events:
    "click .cancel" : "reset"

  setBindings: ->
  
  resetBindings: ->

  preset: ->
    @reloadRegistros(new Date())
    
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
    @html require("views/apps/vistas/verRegistroResumen/layout")(VerRegistrosResumen)
    @viewDate.val new Date().to_salesforce()
    pickers =  @viewDate.datepicker({autoclose: true})
    pickers.on("change",@onDateChange)

  onDateChange: (e) =>
    target = $(e.target)
    date = new Date(target.val())    
    @reloadRegistros(date);

  onRegistroLoaded: (success , results) =>
    #Hack to use REST to load Data for Free Edition Limits
    json  = JSON.stringify results
    Registro.refresh(json)
          
    departamentosList = Registro.uniqueDepartamentos()
    content1 = $("<div class='row-fluid'></div>")
    content2 = $("<div class='row-fluid'></div>")
    content3 = $("<div class='row-fluid'></div>")
    content4 = $("<div class='row-fluid'></div>")
    for departamentoName in departamentosList
      registros = Registro.findAllByAttribute "Departamento" , departamentoName
      departamentoGroup = Registro.groupByTipo(registros)
      if departamentoName == 'ventas credito' or departamentoName == 'ventas contado' or departamentoName == 'impuesto ventas'
        content1.append require("views/apps/vistas/verRegistroResumen/departamento")(Departamento: departamentoName , Tipos: departamentoGroup)
      else if departamentoName == 'cobro' or departamentoName == "saldos"
        content2.append require("views/apps/vistas/verRegistroResumen/departamento")(Departamento: departamentoName , Tipos: departamentoGroup)
      else if departamentoName == 'inventarios valor' or departamentoName == 'inventarios unidad'
        content3.append require("views/apps/vistas/verRegistroResumen/departamento")(Departamento: departamentoName , Tipos: departamentoGroup)
      else
        content4.append require("views/apps/vistas/verRegistroResumen/departamento")(Departamento: departamentoName , Tipos: departamentoGroup)

    @departamentos_list.html content1
    @departamentos_list.append content2
    @departamentos_list.append content3
    @departamentos_list.append content4
    $('.popable').popover()

  reset: ->
    Registro.destroyAll()
    @resetBindings()
    @navigate "/apps"

module.exports = VerRegistrosResumen