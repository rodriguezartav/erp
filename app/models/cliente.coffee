Spine = require('spine')

class Cliente extends Spine.Model
  @configure 'Cliente', 'Name', 'CodigoExterno' , "Activo" , "Saldo" , "DiasCredito"
  @extend Spine.Model.NSyncModel
  @extend Spine.Model.Salesforce
  @extend Spine.Model.SelectableModel

  @avoidQueryList= ["Saldo"]

  @queryFilter: (options) =>
    return "" if !options
    filter = ""
    filter = @queryFilterAddCondition(" Saldo__c != 0"                                 , filter) if options.saldo
    filter = @queryFilterAddCondition(" CreditoAsignado__c > 0 and DiasCredito__c > 0" , filter) if options.credito
    filter

  @to_name_array: ->
    clientes = Cliente.all()
    names = []
    for cliente in clientes
      names.push cliente.Name
    return names



        
module.exports = Cliente