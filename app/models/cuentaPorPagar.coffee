Spine = require('spine')

class CuentaPorPagar extends Spine.Model
  @configure "CuentaPorPagar", "Proveedor" , "Total" , "Saldo" , "Referencia" , "Observacion" , 
  "SubTotal" , "Descuento" , "Impuesto", "Plazo" , "FechaFacturacion","FechaVencimiento" , "TipoCambio" ,
  "CuentaGasto" , "CuentaBanco"
  
  @extend Spine.Model.Salesforce

  @queryFilter: (options ) =>
    return "" if !options
    filter =""
    filter = @queryFilterAddCondition(" Saldo__c   != 0"                             ,  filter)  if options.saldo
    filter = @queryFilterAddCondition(" Proveedor__c = '#{options.proveedor}'"       ,  filter)  if options.proveedor
    filter = @queryFilterAddCondition(" AprobadoParaPagar__c  = true"                ,  filter)  if options.aprobadoParaPagar
    filter


  @insert: (documentos) ->
    documentos = @salesforceFormat(documentos)
    
    $.ajax
      url        : Spine.server + "/rest"
      xhrFields  : {withCredentials: true}
      type       : "POST"
      data       : @ajaxParameters( { name: "Tesoreria" , data: '{"documentos":' + documentos + '}' })
      success    : @on_send_success
      error      : @on_send_error

module.exports = CuentaPorPagar