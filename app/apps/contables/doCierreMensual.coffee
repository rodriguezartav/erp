Spine = require('spine')
Cierre = require("models/cierre")

class DoCierreMensual extends Spine.Controller
  
  className: "row-fluid DoCierre"
  
  @departamento = "Contabilidad"
  @label = "Cierre Mensual"
  @icon = "icon-bar-chart"

  elements:
    ".departamentos_list"       : "departamentos_list"
    ".viewDate"             : "viewDate"

  events:
    "click .cancel" : "reset"
    "click .save"   : "onSaveCierre"

    
  constructor: ->
    super
    @doCierre()

  doCierre: ->
    data=
      restRoute: "Cierre"
      restMethod: "POST"
      restData: {} 
      class: Cierre

    Spine.trigger "show_lightbox" , "rest" , data  , @onCierreComplete
    

  onCierreComplete: (success,results) =>
    #HACKING REST TO CIERRE , WE DONT USE CIERRE YET.....
    @render(    JSON.parse results.results[0].Data__c )
    
  render: (results) ->
    @html require("views/apps/contables/doCierre/layout")(app: DoCierreMensual , cierre: results)
    

  reset: ->
    @navigate "/apps"

module.exports = DoCierreMensual