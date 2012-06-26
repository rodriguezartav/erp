Spine = require('spine')
Cierre = require("models/registro")

class VerCierreDiario extends Spine.Controller
  
  className: "row-fluid verCierreDiario"
  
  @departamento = "Vistas"
  @label = "Cierre Diario"
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
    Registro.destroyAll()
    data=
      restRoute: "CierreDiario"
      restMethod: "GET"
      restData: {}
      class: Registro

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

  onRegistroLoaded: (success , results) =>
    #Hack to use REST to load Data for Free Edition Limits
    console.log results.results[0]
    @cierres_list.html require("views/apps/vistas/verCierreDiario/item")({}) 
    

  reset: ->
    Cierre.destroyAll()
    @resetBindings()
    @navigate "/apps"

module.exports = VerCierreDiario