Spine = require('spine')

class Ajuste extends Spine.Model
  @configure "Ajuste" , "Cuenta" , "Monto" , "Descripcion" , "Tipo"
  @extend Spine.Model.Salesforce

  @queryFilter: (options) =>
    return "" if !options
    filter = ""
    filter = @queryFilterAddCondition(" Clase__c IN (#{options.clases})"   ,  filter)  if options.clases
    filter = @queryFilterAddCondition(" Automatica__c = True"   ,  filter)  if options.automatica
    
    
module.exports = Ajuste

