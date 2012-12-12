Spine = require('spine')

class CuentaPorPagar extends Spine.Model
  @configure "CuentaPorPagar" , "Saldo" , "Referencia" , "Observacion" , "FechaFacturacion", "FechaVencimiento" , "FechaPagoProgramado" , 
  "TipoCambio" , "NombreProveedor", "Estado",  "FlagedToSave" , "ReferenciaFormaPago" , "FormaPago" , "Fecha_de_Pago" , "Total" , "Enviado",
  "Proveedor" , "Proveedor__r.Tipo"
  
  @extend Spine.Model.SalesforceModel
  @extend Spine.Model.SalesforceAjax.Methods  


  @avoidInsertList = ["FlagedToSave" , "FechaVencimiento" , "ReferenciaFormaPago" , "FormaPago" ,"FechaFacturacion" ,  "Referencia", "NombreProveedor",
   "Observacion", "Saldo", "TipoCambio","Total","Fecha_de_Pago" , "Proveedor__r.Tipo"]
  
  @avoidQueryList = ["FlagedToSave"]

  @queryFilter: (options ) =>
    return "" if !options
    filter =""
    filter = @queryFilterAddCondition(" Estado__c   IN ('Pendiente','Calendarizado','Para Pagar') " ,  filter)  if options.forWorkflow
    filter = @queryFilterAddCondition(" Estado__c   IN (#{options.estado})"          ,  filter)  if options.estado
    filter = @queryFilterAddCondition(" Saldo__c   != 0"                             ,  filter)  if options.saldo
    filter = @queryFilterAddCondition(" Proveedor__c = '#{options.proveedor}'"       ,  filter)  if options.proveedor
    filter = @queryOrderAddCondition(" order by FechaVencimiento__c "               , filter)  if options.orderFechaVencimiento
    filter


  getFechaVencimiento: =>
    date =  Date.parse(@FechaVencimiento)
    date = new Date(date)
    return date
    
  getFechaPagoProgramado: =>
    date =  Date.parse(@FechaPagoProgramado)
    date = new Date(date)
    return date
    
    
  getFecha_de_Pago: =>
    date =  Date.parse(@Fecha_de_Pago)
    date = new Date(date)
    return date
    


module.exports = CuentaPorPagar