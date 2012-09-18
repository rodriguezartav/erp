Spine = require('spine')

class Cierre extends Spine.Model
  @configure "Cierre" , "Name" , "Tipo" , "Fecha" , "Data"
 
  @extend Spine.Model.SalesforceModel
  @extend Spine.Model.SalesforceAjax.Methods  
    
    
  getDia: ->
    date = new Date(Date.parse(@Fecha,"yyyy/dd/MM"));
    dia = date.getDate() + 1
    return if dia == 32 then 1 else dia
    
  getDepartamentoData: (departamento) ->
    data = JSON.parse @Data
    return data[departamento]
    
  @queryFilter: (options) =>
    allowedTypes =  ''#@getFilterByProfile()
  
    return "" if !options
    filter = ""
    filter = @queryFilterAddCondition(" Fecha__c >= #{options.fechaIni} and Fecha__c <= #{options.fechaFin}" , filter) if options.fechaIni and options.fechaFin
    filter = @queryFilterAddCondition(" Fecha__c = TODAY "                , filter)   if options.today
    filter = @queryFilterAddCondition(" Fecha__c = YESTERDAY "                , filter)   if options.yesterday
    filter = @queryFilterAddCondition(" Fecha__c = THIS_MONTH "                , filter)   if options.month
    filter = @queryFilterAddCondition(" Fecha__c = #{options.fecha} "       , filter)   if options.fecha
    filter = @queryOrderAddCondition(" order by Fecha__c "                , filter)
  
    
module.exports = Cierre

