Spine = require('spine')

class Deposito extends Spine.Model
  @configure 'Deposito' , "Name" , "Monto" , "Referencia" , "Estado"

  @extend Spine.Model.SalesforceModel
  @extend Spine.Model.SalesforceAjax.Methods    


  @queryFilter: (options ) =>
     return "" if !options
     filter = ""
   #  filter = @queryFilterAddCondition(" Cliente__c = '#{options.cliente.id}' "       ,  filter)  if options.cliente
     filter

module.exports = Deposito