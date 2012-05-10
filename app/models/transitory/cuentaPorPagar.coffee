Spine = require('spine')

class CuentaPorPagar extends Spine.Model
  @configure "CuentaPorPagar" , "Saldo" , "Referencia" , "Observacion" , "FechaFacturacion", "FechaVencimiento" , "FechaPagoProgramado" , 
  "TipoCambio" , "NombreProveedor", "Estado",  "FlagedToSave" , "ReferenciaFormaPago" , "FormaPago"
  
  @extend Spine.Model.Salesforce

  @avoidInsertList = ["FlagedToSave" , "FechaVencimiento" , "ReferenciaFormaPago" , "FormaPago" ,"FechaFacturacion" ,  "Referencia", "NombreProveedor", "Observacion", "Saldo",
  "TipoCambio"]
  
  @avoidQueryList = ["FlagedToSave"]

  @queryFilter: (options ) =>
    return "" if !options
    filter =""
    filter = @queryFilterAddCondition(" Estado__c   IN (#{options.estado})"          ,  filter)  if options.estado
    filter = @queryFilterAddCondition(" Saldo__c   != 0"                             ,  filter)  if options.saldo
    filter = @queryFilterAddCondition(" Proveedor__c = '#{options.proveedor}'"       ,  filter)  if options.proveedor
    filter = @queryFilterAddCondition(" AprobadoParaPagar__c  = true"                ,  filter)  if options.aprobadoParaPagar
    filter = @queryOrderAddCondition(" order by FechaVencimiento__c "               , filter)  if options.orderFechaVencimiento
    filter



module.exports = CuentaPorPagar