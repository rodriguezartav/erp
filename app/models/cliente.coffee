Spine = require('spine')

class Cliente extends Spine.Model
  @configure 'Cliente', 'Name', 'CodigoExterno' , "Activo" , "Saldo" , "DiasCredito" , "CreditoAsignado" , "Rating_Crediticio",
  "Negociacion" , "LastModifiedDate" , "Ruta" , "Transporte" , "Direccion" , "Telefono"  , "RutaTransporte" , "AQuienLlamoLlamar" , 
  "AQuienLlamoRazon"

  @extend Spine.Model.SalesforceModel
  @extend Spine.Model.SalesforceAjax

  @extend Spine.Model.SocketModel
  @extend Spine.Model.SelectableModel

  @autoQueryTimeBased = true

  @avoidInsertList = ["Name","Rating_Crediticio","CodigoExterno","Activo","Saldo","DiasCredito" , "LastModifiedDate"]

  @overrideInitQuery = { credito: true }

  @queryFilter: (options) =>
    return "" if !options
    filter = ""
    filter = @queryFilterAddCondition(" Activo__c != 0"                                 , filter) if options.activo
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

  validate: ->
    unless @Name
      "El nombre del cliente es obligatorio"

  willOverDraft: (monto) ->
    od = false
    od = true if monto + @Saldo > @CreditoAsignado
    return od

module.exports = Cliente