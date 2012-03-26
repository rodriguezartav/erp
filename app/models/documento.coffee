Spine = require('spine')

class Documento extends Spine.Model
  @configure "Documento", "Proveedor" , "Nombre_Contado" ,"Total" , "Saldo" , "CodigoExterno" , "Referencia" , "Observacion" , 
  "SubTotal" , "Descuento" , "Impuesto", "Fuente" , "Cliente" , "Plazo" , "FechaFacturacion","FechaVencimiento" ,
  "AplicarACuenta" , "Tipo_de_Documento" , "PagoEnRecibos"
  
  @extend Spine.Model.Salesforce

  @avoidQueryList: [ "Referencia" , "Observacion" , "SubTotal" , "Descuento" , "Impuesto", "Fuente" ,
    "FechaFacturacion","FechaVencimiento" ,"AplicarACuenta"]

  @queryFilter: (options ) =>
    return "" if !options
    filter =""
    filter = @queryFilterAddCondition(" Saldo__c   != 0"                               , filter) if options.saldo
    filter = @queryFilterAddCondition(" Proveedor__c = '#{options.proveedor}'"           , filter) if options.proveedor
    filter = @queryFilterAddCondition(" Tipo_de_Documento__c IN (#{options.tipos}) "   , filter) if options.tipos
    filter = @queryFilterAddCondition(" Cliente__c = '#{options.cliente.id}' "         , filter) if options.cliente
    filter = @queryFilterAddCondition(" Estado__c  = '#{options.estado}'"              , filter) if options.estado
    filter

module.exports = Documento

