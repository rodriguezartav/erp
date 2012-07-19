Spine = require('spine')
Cierre = require("models/cierre")

class DoCierreDiario extends Spine.Controller
  
  className: "row-fluid DoCierreDiario"
  
  @departamento = "Contabilidad"
  @label = "Cierre Diario"
  @icon = "icon-eye-open"

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
      restRoute: "CierreDiario"
      restMethod: "POST"
      restData: {} 
      class: Cierre

    Spine.trigger "show_lightbox" , "rest" , data  , @onCierreComplete
    

  onCierreComplete: (success,results) =>
    #HACKING REST TO CIERRE , WE DONT USE CIERRE YET.....
    @render(    JSON.parse results.results[0].Data__c )
    
  render: (results) ->
    @html require("views/apps/contables/doCierre/layout")(app: DoCierreDiario , cierre: results)
    

  reset: ->
    @navigate "/apps"

module.exports = DoCierreDiario