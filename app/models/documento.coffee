Spine = require('spine')

class Documento extends Spine.Model
  @configure "Documento" , "Nombre_Contado" ,"Total" , "Saldo" , "Consecutivo" , "Referencia" , "Observacion" , "Transporte",
  "SubTotal" , "Descuento" , "Impuesto", "Fuente" , "Cliente" , "Plazo", "PlazoActual" , "FechaFacturacion","FechaVencimiento" ,
   "Tipo_de_Documento" ,  "IsContado" ,"Estado" , "Autorizado" , "MontoEnRecibos" , "FechaEntrega" , "OrdenEntrega","Entregado" ,
   "EntregadoRuta" , "EntregadoEmpaque" , "EntregadoValor" , "EntregadoGuia"  , "FechaEntregaPropuesta"

  @extend Spine.Model.SalesforceModel
  @extend Spine.Model.SalesforceAjax.Methods

  @avoidQueryList: [ "Fuente" ,"IsContado"]
  @avoidInsertList: ["FechaVencimiento" , "PlazoActual" , "FechaEntregaPropuesta" ]

  updateFromMovimientos: (movimientos)  ->
    @Total = 0
    @Descuento =0
    @Impuesto = 0
    @SubTotal=0
    for movimiento in movimientos
      @SubTotal += movimiento.SubTotal
      @Descuento += movimiento.Descuento
      @Impuesto += movimiento.Impuesto
      @Total += movimiento.Total
    
  @queryFilter: (options ) =>
    return "" if !options
    filter =""

    filter = @queryFilterAddCondition( "Tipo_de_Documento__c IN ('NC' , 'ND') and ( Autorizado__c = false or Estado__c != 'Impreso'  )" ,  filter)  if options.livecycle
    filter = @queryFilterAddCondition( "Tipo_de_Documento__c = 'FA' and isContado__c = true and isEntregado__c = false" ,  filter)  if options.contadoSinEntregar
    filter = @queryFilterAddCondition(" Saldo__c   != 0"                             ,  filter)  if options.saldo
    filter = @queryFilterAddCondition(" Proveedor__c = '#{options.proveedor}'"       ,  filter)  if options.proveedor
    filter = @queryFilterAddCondition(" Tipo_de_Documento__c IN (#{options.tipos}) " ,  filter)  if options.tipos
    filter = @queryFilterAddCondition(" Cliente__c = '#{options.cliente.id}' "       ,  filter)  if options.cliente
    filter = @queryFilterAddCondition(" FechaFacturacion__c=#{options.fecha} "     ,  filter)  if options.fecha
    filter = @queryFilterAddCondition(" Estado__c  = '#{options.estado}'"            ,  filter)  if options.estado
    filter = @queryFilterAddCondition(" Estado__c IN (#{options.estados}) "            ,  filter)  if options.estados
    filter = @queryFilterAddCondition(" AprobadoParaPagar__c  = true"                ,  filter)  if options.aprobadoParaPagar
    filter = @queryFilterAddCondition(" Autorizado__c   = #{options.autorizado }"           , filter)   if options.autorizado == false or options.autorizado == true
    filter = @queryFilterAddCondition(" enRecibo__c        = false"                ,  filter)  if options.enRecibo
    filter = @queryFilterAddCondition(" Tipo_de_Documento__c = 'FA' and Entregado__c  = false and Transporte__c != 'Cliente Retira'"  ,  filter)  if options.sinEntregar
    filter = @queryFilterAddCondition(" InvoiceVersion__c       = 2"                ,  filter)  if options.v2
    filter = @queryOrderAddCondition(" order by Consecutivo__c "                   , filter)  
    filter
    

  @markedPrinted: (documento) ->
    $.ajax
      url        : Spine.server + "/rest"
      xhrFields  : {withCredentials: true}
      type       : "POST"
      data       : @ajaxParameters( { name: "Print" , data: JSON.stringify( { documentoId: documento.id } ) } )

module.exports = Documento