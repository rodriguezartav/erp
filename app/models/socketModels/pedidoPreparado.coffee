Spine = require('spine')

class PedidoPreparado extends Spine.Model
  @configure 'Pedido' , "Cliente", "Producto" , "Cantidad" , "Precio" , 
  "Impuesto" , "Descuento" , "SubTotal" , "Total" , "Referencia","Estado"
  
  @extend Spine.Model.Salesforce
  @extend Spine.Model.SocketModel

  @autoQuery = true;
  @autoQueryTimeBased   :   false

  @overrideName = "Oportunidad"

  @destroyBeforeRefresh = true;

  @beforeSocketUpdate: (results) =>
    for result in results
      @lastNotificationEstado = result['Estado']
      @lastNotificationCliente = result['Cliente']
    return true;

  @group_by_referencia: (pedidos) ->    
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
    filter = @queryFilterAddCondition(" Especial  = true               "               , filter) if options.especial == true
    filter = @queryFilterAddCondition(" Especial  = false               "              , filter) if options.especial == false
    
    filter

module.exports = PedidoPreparado