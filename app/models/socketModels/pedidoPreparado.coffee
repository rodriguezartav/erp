Spine = require('spine')

class PedidoPreparado extends Spine.Model
  @configure 'Pedido' , "Cliente", "Producto" , "Cantidad" , "Precio" , "CreatedById", "Documento" , "Orden" ,
  "Impuesto" , "Descuento" , "SubTotal" , "Total" , "Referencia" , "Estado" , "Especial" , "LastModifiedDate"
  
  @extend Spine.Model.SalesforceModel
  @extend Spine.Model.SalesforceAjax.Methods
  @extend Spine.Model.SocketModel

  @overrideName = "Oportunidad"
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
      groups.push {Referencia: referencia , Orden: pedidos_in_referencia[0].Orden ,  Documento: pedidos_in_referencia[0].Documento,  Estado: pedidos_in_referencia[0].Estado ,  Especial: pedidos_in_referencia[0].Especial ,  CreatedById: pedidos_in_referencia[0].CreatedById ,  Pedidos: pedidos_in_referencia , Cliente: pedidos_in_referencia[0].Cliente , Total: total} if pedidos_in_referencia.length > 0
    groups

  @queryFilter: (options ) =>
    filter =""
    filter = @queryFilterAddCondition(" Estado__c  = 'Pendiente' or LastModifiedDate = TODAY" , filter)
    
    filter

module.exports = PedidoPreparado