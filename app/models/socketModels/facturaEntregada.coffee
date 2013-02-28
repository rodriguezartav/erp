Spine = require('spine')

class FacturaEntregada extends Spine.Model
  @configure "Documento" , "Consecutivo" , "Observacion" , "Transporte",
    "Cliente" , "Plazo" , "FechaFacturacion" , "Referencia"
    "Autorizado" , "FechaEntrega" , "OrdenEntrega","Entregado" , "FechaVencimiento"  , "Total"
    "EntregadoRuta" , "EntregadoEmpaque" , "EntregadoValor" , "EntregadoGuia"  , "FechaEntregaPropuesta" , "FechaPedido"

  @extend Spine.Model.SalesforceModel
  @extend Spine.Model.SalesforceAjax.Methods
  @extend Spine.Model.SocketModel

  @avoidQueryList: []
  @avoidInsertList: [ "FechaEntregaPropuesta" , "Total" , "FechaVencimiento" , "FechaPedido" , "Referencia" , "Transporte" , "Observacion" , "Consecutivo" , "FechaFacturacion" , "Cliente" ]

  hasEntregadoRuta: =>
    return false if !@EntregadoRuta
    return false if @EntregadoRuta.length < 2
    return true

  hasEntregadoEmpaque: =>
    return false if !@EntregadoEmpaque
    return false if @EntregadoEmpaque.length < 2
    return true

  generalTransporte: ->
    if @Transporte.indexOf("Cliente") > -1 
      return "Cliente"
    else if @Transporte.indexOf("Agente") > -1 
      return "Agente"
    if @Transporte.indexOf("Rodco") > -1 
      return "Rodco"
    else
      return "Transporte"

  @queryFilter: (options ) =>
    return "" if !options
    filter = ""
    filter = @queryFilterAddCondition(" Tipo_de_Documento__c = 'FA' and Entregado__c  = false and Total__c > 0"  ,  filter)  if options.sinEntregar
    filter = @queryFilterAddCondition(" InvoiceVersion__c       = 2"                ,  filter)  if options.v2
    filter = @queryOrderAddCondition(" order by Consecutivo__c "                   , filter)  
    filter

module.exports = FacturaEntregada