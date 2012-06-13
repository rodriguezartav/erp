Spine = require('spine')

class Cliente extends Spine.Model
  @configure 'Cliente', 'Name', 'CodigoExterno' , "Activo" , "Saldo" , "DiasCredito" , "CreditoAsignado","Rating_Crediticio",
  "Negociacion"

  @extend Spine.Model.Salesforce
  @extend Spine.Model.SocketModel
  @extend Spine.Model.SelectableModel

  @autoQueryTimeBased = true

  @avoidInsertList = ["Name","Rating_Crediticio","CodigoExterno","Activo","Saldo","DiasCredito"]

  @queryFilter: (options) =>
    return "" if !options
    filter = ""
    filter = @queryFilterAddCondition(" Saldo__c != 0"                                 , filter) if options.saldo
    filter = @queryFilterAddCondition(" CreditoAsignado__c > 0 and DiasCredito__c > 0" , filter) if options.credito
    filter = @queryFilterAddCondition(" CreditoAsignado__c = 0 and DiasCredito__c = 0" , filter) if options.contado
    filter

  @to_name_array: ->
    clientes = Cliente.all()
    names = []
    for cliente in clientes
      names.push cliente.Name
    return names


  willOverDraft: (monto) ->
    od = false
    od = true if monto + @Saldo > @CreditoAsignado
    return od

        
module.exports = Cliente