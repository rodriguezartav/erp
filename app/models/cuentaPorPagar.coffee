Spine = require('spine')

class CuentaPorPagar extends Spine.Model
  @configure "CuentaPorPagar", "Proveedor" , "Total" , "Saldo" , "Referencia" , "Observacion" , 
  "SubTotal" , "Descuento" , "Impuesto", "Plazo" , "FechaFacturacion","FechaVencimiento" , "FechaPagoProgramado" , "TipoCambio" ,
  "NombreProveedor" , "FlagedToSave" , "Tipo_de_Documento" , "FechaIngreso","Estado"
  
  @extend Spine.Model.SalesforceModel
  @extend Spine.Model.SalesforceAjax.Methods

  @avoidInsertList = ["FlagedToSave"]
  @avoidQueryList =  ["FlagedToSave"]

  

  @queryFilter: (options ) =>
    return "" if !options
    filter =""
    filter = @queryFilterAddCondition(" Estado__c   IN (#{options.estado})"          ,  filter)  if options.estado
    filter = @queryFilterAddCondition(" Saldo__c   != 0"                             ,  filter)  if options.saldo
    filter = @queryFilterAddCondition(" FechaIngreso__c = #{options.fecha} "            ,  filter)  if options.fecha
    filter = @queryFilterAddCondition(" Estado__c IN ('Para Pagar','Calendarizado') and FechaPagoProgramado__c <= TODAY " ,  filter)  if options.paraPagar
    filter = @queryFilterAddCondition(" Proveedor__c = '#{options.proveedor}'"       ,  filter)  if options.proveedor
    filter = @queryFilterAddCondition(" AprobadoParaPagar__c  = true"                ,  filter)  if options.aprobadoParaPagar
    filter = @queryOrderAddCondition(" order by FechaVencimiento__c "               , filter)  if options.orderFechaVencimiento
    filter

module.exports = CuentaPorPagar