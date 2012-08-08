Spine = require('spine')

class PedidoPreparado extends Spine.Model
  @configure 'Pedido' , "Cliente", "Producto" , "Cantidad" , "Precio" , 
  "Impuesto" , "Descuento" , "SubTotal" , "Total" , "Referencia","Estado" , "Especial"
  
  @extend Spine.Model.Salesforce
  @extend Spine.Model.SocketModel

  @overrideName = "Oportunidad"
  @autoQuery = true;
  @autoQueryTimeBased   :   false
  #Turned On only for certain profiles in SecurityManager
  @autoQuery = false
  @destroyBeforeRefresh = true;


  @afterSocketUpdate: (message, results) =>



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
    filter = @queryFilterAddCondition(" Especial__c  = true               "               , filter) if options.especial == true
    filter = @queryFilterAddCondition(" Especial__c  = false               "              , filter) if options.especial == false
    
    filter

module.exports = PedidoPreparado