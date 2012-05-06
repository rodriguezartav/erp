Spine = require('spine')

class Saldo extends Spine.Model
  @configure "Saldo" , "Total" , "Saldo" , "Consecutivo" ,  "Cliente" , "Plazo" , "FechaFacturacion" , "FechaVencimiento" ,
    "Tipo_de_Documento" , "PagoEnRecibos" , "Restricciones"

  @extend Spine.Model.Salesforce
  @extend Spine.Model.SocketModel

  @autoQuery = false
  @overrideName: "Documento"

  @queryFilter: (options ) =>
    filter = ""
    filter = @queryFilterAddCondition(" IsContable__c = 'true' and IsContado__c = false" , filter)
    filter = @queryFilterAddCondition(" Cliente__c = '#{options.cliente.id}' "         , filter) if options.cliente
    filter

module.exports = Saldo

