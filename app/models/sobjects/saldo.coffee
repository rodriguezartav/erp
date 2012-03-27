Spine = require('spine')

class Saldo extends Spine.Model
  @configure "Saldo" , "Total" , "Saldo" , "CodigoExterno" ,  "Cliente" , "Plazo" , "FechaFacturacion" , "FechaVencimiento" ,
    "Tipo_de_Documento" , "PagoEnRecibos" , "Restricciones"

  @extend Spine.Model.Salesforce
  @extend Spine.Model.NSyncModel


  @overrideName: "Documento"

  @queryFilter: (options ) =>
    filter =""
    filter = @queryFilterAddCondition(" Saldo__c   != 0"                               , filter)
    filter = @queryFilterAddCondition(" Cliente__c = '#{options.cliente.id}' "         , filter) if options.cliente
    filter

module.exports = Saldo

