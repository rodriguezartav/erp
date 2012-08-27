Spine = require('spine')
Cierre = require("models/cierre")

class VerCierreDiario extends Spine.Controller
  
  className: "row-fluid verCierreDiario"
  
  @departamento = "Contabilidad"
  @label = "Ver Cierre Diario"
  @icon = "icon-file"

  elements:
    ".cierres_list"       : "cierres_list"
    ".viewDate"             : "viewDate"
    ".fecha"               : "fecha"

  events:
    "click .cancel" : "reset"

  setBindings: ->
  
  resetBindings: ->

  preset: ->
    @reloadCierres()
    
  constructor: ->
    super
    @preset()
    @render()
    @setBindings()

  reloadCierres: (date) ->
    Cierre.destroyAll()
    Cierre.ajax().query( { yesterday: true } , afterSuccess: @onCierreLoaded ) if !date
    Cierre.ajax().query( { fecha: data.to_salesforce_date() } , afterSuccess: @onCierreLoaded )

  render: ->
    @html require("views/apps/vistas/verCierreDiario/layout")(VerCierreDiario)
    @viewDate.val new Date().to_salesforce()
    pickers =  @viewDate.datepicker({autoclose: true})
    pickers.on("change",@onDateChange)

  onDateChange: (e) =>
    target = $(e.target)
    date = new Date(target.val())    
    @reloadCierres(date);

  onCierreLoaded: () =>
    return if Cierre.count() == 0
    parsed = JSON.parse Cierre.first().Data
    console.log parsed
    values = []
    if parsed
      for index,value of parsed
        values.push  index: index , value: value
      @cierres_list.html require("views/apps/vistas/verCierreDiario/item")(values) 
    else
      @cierres_list.html "<tr><td>No hay cierres para esta fecha</td></tr>"

  reset: ->
    Cierre.destroyAll()
    @resetBindings()
    @navigate "/apps"

module.exports = VerCierreDiario