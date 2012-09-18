Spine = require('spine')
Cierre = require("models/cierre")
Registro = require("models/registro")

class VerCierreMensual extends Spine.Controller
  
  className: "row-fluid verCierreDiario"
  
  @departamento = "Contabilidad"
  @label = "Ver Cierre Mensual"
  @icon = "icon-file"

  elements:
    ".cierres_list"   : "cierres_list"
    ".departamentos"  : "departamentosUL"
    ".viewDate"             : "viewDate"
    ".analisis_list" : "analisis_list"

  events:
    "click .departamentos>li>a"  :  "onDepartamentosClick"

  constructor: ->
    super
    @html require("views/apps/vistas/verCierreMensual/step1")(VerCierreMensual)
    pickers =  @viewDate.datepicker({autoclose: true})
    pickers.on("change",@onDateChange)

  onDateChange: (e) =>
    target = $(e.target)
    @currentDate = new Date(target.val())  
    @selectedDia = @currentDate.getDate()
    @reloadCierres(@currentDate);
    
    
  reloadCierres: (date) ->
    Cierre.destroyAll()
    fechaIni = new Date(date.getFullYear() , date.getMonth() , 0 ).to_salesforce_date()
    fechaFin = new Date(date.getFullYear() , date.getMonth() + 1 , 0 ).to_salesforce_date()
    
    Cierre.ajax().query( { fechaIni: fechaIni, fechaFin: fechaFin } , afterSuccess: @onCierreLoaded )

    Registro.destroyAll()
    data=
      restRoute: "Registros"
      restMethod: "POST"
      restData: { year: date.getFullYear() , month: date.getMonth() + 1 , day: 0 , tipos: Registro.getAllowedDepartamentos()  }
      class: Registro
    Spine.trigger "show_lightbox" , "rest" , data  , @onRegistroLoaded

  onCierreLoaded: () =>
    @render()

  onRegistroLoaded: (success , results) =>
    #Hack to use REST to load Data for Free Edition Limits
    json  = JSON.stringify results
    Registro.refresh(json)
    @render()

  render: =>
    return false if Registro.count() == 0 or Cierre.count() == 0
    @html require("views/apps/vistas/verCierreMensual/layout")(VerCierreMensual)
    @departamentos = Registro.uniqueDepartamentos()
    for departamentoName in @departamentos
      @departamentosUL.append "<li data-name='#{departamentoName}'><a>#{departamentoName}</a></li>"
    
    @mapRegistros()
    @mapCierres()
    console.log @cierres

  
  n: ->
    @analisis_list.empty()
    value = @firstCierre[@selectedDepartamento]
    console.log @firstCierre
    console.log value

    for day in [1..31]
      row = {dia: "" , registro: 0 , cierre: 0 , prueba: 0}
      row.dia = day
      if @registros[day] && @cierres[day]
        row.registro = @registros[day].byTipo[@selectedDepartamento]?.Monto || 0
        value += row.registro
        row.cierre = @cierres[day][@selectedDepartamento] || 0
        row.prueba = value - @cierres[day][@selectedDepartamento]
      @analisis_list.append require("views/apps/vistas/verCierreMensual/item")(row)

  onDepartamentosClick: (e) =>
    target = $(e.target).parents "li"
    @departamentosUL.find("li").removeClass "active"
    target.addClass "active"
    @selectedDepartamento = target.attr "data-name"
    @n()

  mapCierres: ->
    @cierres = {}
    @firstCierre = JSON.parse Cierre.first().Data
    Cierre.first().destroy()
    for cierre in Cierre.all()
      dia = cierre.getDia()
      @cierres[dia] = JSON.parse cierre.Data

  mapRegistros: () ->
    @registros = {}
    for registro in Registro.all()
      dia = registro.getDia()
      @registros[dia] = { all: [] , byTipo: {} } if !@registros[dia]
      @registros[dia].all.push registro

    for index , registroDiaGroup of @registros
      groups = Registro.groupByDepartamento(registroDiaGroup.all)
      registroDiaGroup.byTipo = groups

  reset: ->
    Cierre.destroyAll()
    @navigate "/apps"

module.exports = VerCierreMensual