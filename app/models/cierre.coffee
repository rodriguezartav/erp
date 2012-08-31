Spine = require('spine')

class Cierre extends Spine.Model
  @configure "Cierre" , "Name" , "Tipo" , "Fecha" , "Data"
 
  @extend Spine.Model.SalesforceModel
  @extend Spine.Model.SalesforceAjax.Methods  
    
    
  @queryFilter: (options) =>
    allowedTypes =  ''#@getFilterByProfile()
  
    return "" if !options
    filter = ""
    filter = @queryFilterAddCondition(" Fecha__c = TODAY "                , filter)   if options.today
    filter = @queryFilterAddCondition(" Fecha__c = YESTERDAY "                , filter)   if options.yesterday
    filter = @queryFilterAddCondition(" Fecha__c = #{options.fecha} "       , filter)   if options.fecha
    filter = @queryOrderAddCondition(" order by Fecha__c "                , filter)
  
    
module.exports = Cierre

