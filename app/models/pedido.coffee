Spine = require('spine')

class Pedido extends Spine.Model
  @configure 'Pedido' , "Cliente", "Producto" , "Cantidad" , "Precio" , 
  "Impuesto" , "Descuento" , "SubTotal" , "Total" , "Referencia"
  
  @extend Spine.Model.Salesforce

  @overrideName = "Oportunidad"

  @destroyBeforeRefresh = true;

  @aprobar: (ids,observacion,aprobar) ->
    $.ajax
      url        : Spine.server + "/rest"
      xhrFields  : {withCredentials: true}
      type       : "POST"
      data       : @ajaxParameters( { name: "Oportunidad" , data: JSON.stringify( { ids: ids , observacion: observacion , aprobar: aprobar } ) } )
      success    : @on_send_success
      error      : @on_send_error

  @group_by_referencia: () ->
    pedidos = Pedido.all()
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
    return "" if !options
    filter =""
    filter = @queryFilterAddCondition(" Estado__c  = '#{options.estado}'"              , filter) if options.estado
    filter





module.exports = Pedido