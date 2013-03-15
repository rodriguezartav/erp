Spine = require('spine')

class PedidoPreparado extends Spine.Model
  @configure 'Pedido' , "Cliente", "Producto" , "Cantidad" , "Precio" , "CreatedById", "Documento" , "Orden" ,"Observacion",
  "Impuesto" , "Descuento" , "SubTotal" , "Total" , "Referencia" , "Estado" , "Especial" , "LastModifiedDate" , "CodigoExterno"
  
  @extend Spine.Model.SalesforceModel
  @extend Spine.Model.SalesforceAjax.Methods
  @extend Spine.Model.SocketModel

  @overrideName = "Oportunidad"
  @autoQueryTimeBased   =   false;
  #Turned On only for certain profiles in SecurityManager
  @autoQuery = false
  @destroyBeforeRefresh = true;

  @afterSocketUpdate: (message, results) =>


  @group_by_codigoexterno: (pedidos) ->    
    codigosexternos = (pedido.CodigoExterno for pedido in pedidos).unique()
    groups  = []
    for codigoexterno in codigosexternos
      pedidos_with_codigoexterno = []
      total = 0
      subtotal =0
      descuento=0
      impuesto=0
      for pedido in pedidos when pedido.CodigoExterno == codigoexterno
        pedidos_with_codigoexterno.push pedido
        total += pedido.Total
        subtotal += pedido.Total
        descuento += pedido.Subtotal * (pedido.Descuento/100)
      impuesto = total - (total / (1 + (pedidos_with_codigoexterno[0].Impuesto /100) ))
      groups.push {Observacion: pedidos_with_codigoexterno[0].Observacion , CodigoExterno: codigoexterno , Referencia: pedidos_with_codigoexterno[0].Referencia , Orden: pedidos_with_codigoexterno[0].Orden ,  Documento: pedidos_with_codigoexterno[0].Documento,  Estado: pedidos_with_codigoexterno[0].Estado ,  Especial: pedidos_with_codigoexterno[0].Especial ,  CreatedById: pedidos_with_codigoexterno[0].CreatedById ,  Pedidos: pedidos_with_codigoexterno , Cliente: pedidos_with_codigoexterno[0].Cliente , SubTotal: subtotal ,Descuento: descuento, Impuesto: impuesto, Total: total} if pedidos_with_codigoexterno.length > 0
    groups

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
    filter = @queryFilterAddCondition(" Estado__c  IN ( 'Pendiente' , 'Aprobado' ,'Archivado' ) or LastModifiedDate = TODAY" , filter)
    
    filter

module.exports = PedidoPreparado