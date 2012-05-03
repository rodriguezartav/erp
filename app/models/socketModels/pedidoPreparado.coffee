Spine = require('spine')

class PedidoPreparado extends Spine.Model
  @configure 'Pedido' , "Cliente", "Producto" , "Cantidad" , "Precio" , 
  "Impuesto" , "Descuento" , "SubTotal" , "Total" , "Referencia","Estado"
  
  @extend Spine.Model.Salesforce
  @extend Spine.Model.SocketModel

  @autoReQuery = true;

  @overrideName = "Oportunidad"

  @destroyBeforeRefresh = true;

  @beforeSocketUpdate: (results) ->
    acceptResults = true
    for result in results
      acceptResults = false if result['Estado'] != "Pendiente"
    return acceptResults;
      

  @aprobar: (ids,observacion,aprobar) ->
    $.ajax
      url        : Spine.server + "/rest"
      xhrFields  : {withCredentials: true}
      type       : "PUT"
      data       : @ajaxParameters( { name: "Oportunidad" , data: JSON.stringify( { ids: ids , observacion: observacion , aprobar: aprobar } ) } )
      success    : @on_send_success
      error      : @on_send_error

  @group_by_referencia: () ->
    pedidos = PedidoPreparado.all()
    referencias = (pedido.Referencia for pedido in pedidos).unique()
    groups  = []
    for referencia in referencias
      pedidos_in_referencia = []
      total = 0
      for pedido in pedidos when pedido.Referencia == referencia
        pedidos_in_referencia.push pedido
        total += pedido.Total
      groups.push {Referencia: referencia , Pedidos: pedidos_in_referencia , Cliente: pedidos_in_referencia[0].Cliente , Total: total} if pedidos_in_referencia.length > 0
    groups

  @queryFilter: (options ) =>
    filter =""
    filter = @queryFilterAddCondition(" Estado__c  = 'Pendiente'" , filter)
    filter

module.exports = PedidoPreparado