Spine = require('spine')

class Cuenta extends Spine.Model
  @configure "Cuenta" , "Name" , "Codigo" , "Automatica"

  @extend Spine.Model.SalesforceModel
  @extend Spine.Model.SalesforceAjax.Methods

  @queryFilter: (options) =>
    return "" if !options
    filter = "where Clase__c IN (#{options.clases})"
    filter = @queryOrderAddCondition(" order by Codigo__c "                , filter)
    

 

module.exports = Cuenta

