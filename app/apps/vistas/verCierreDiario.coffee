Spine = require('spine')
Cierre = require("models/registro")

class VerCierreDiario extends Spine.Controller
  
  className: "row-fluid verCierreDiario"
  
  @departamento = "Vistas"
  @label = "Ver Cierre Diario"
  @icon = "icon-eye-open"

  elements:
    ".cierres_list"       : "cierres_list"
    ".viewDate"             : "viewDate"

  events:
    "click .cancel" : "reset"
    

  setBindings: ->
  
  resetBindings: ->

  preset: ->
    @reloadCierres(new Date())
    
  constructor: ->
    super
    @preset()
    @render()
    @setBindings()

  reloadCierres: (date) ->
    Cierre.destroyAll()
    data=
      restRoute: "CierreDiario"
      restMethod: "GET"
      restData: date.to_salesforce_date()
      class: Cierre

    Spine.trigger "show_lightbox" , "rest" , data  , @onCierreLoaded

  render: ->
    @html require("views/apps/vistas/verCierreDiario/layout")(VerCierreDiario)
    @viewDate.val new Date().to_salesforce()
    pickers =  @viewDate.datepicker({autoclose: true})
    pickers.on("change",@onDateChange)

  onDateChange: (e) =>
    target = $(e.target)
    date = new Date(target.val())    
    @reloadCierres(date);

  onCierreLoaded: (success , results) =>
    #Hack to use REST to load Data for Free Edition Limits
    parsed = JSON.parse results.results[0]?.Data__c
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