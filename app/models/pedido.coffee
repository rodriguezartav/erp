Spine = require('spine')

class Pedido extends Spine.Model
  @configure 'Pedido', "NombreCliente" , "NombreProducto" , "Cliente", "Producto" , "Cantidad" , "Precio" , 
  "Impuesto" , "Descuento" , "SubTotal" , "Total" , "Referencia"
  @extend Spine.Model.Salesforce

  @group_by_referencia: () ->
    pedidos = Pedido.all()
    referencias = (pedido.Referencia for pedido in pedidos).unique()
    groups  = []
    for referencia in referencias
      pedido_in_referencia = []
      for pedido in pedidos when pedido.Referencia == referencia
        pedido_in_referencia.push pedido
      groups.push {referencia: referencia , pedidos: pedido_in_referencia , cliente: pedido_in_referencia[0].NombreCliente } if pedido_in_referencia.length > 0
    groups

  @fetch_from_sf: (user, options ) ->
     query += " and Estado__c = '#{options.estado}' " if options.estado


  @descuento_monto: (pedido) =>
    monto = 0
    if pedido.Descuento < 35
      subtotal = (Math.round pedido.Precio * pedido.Cantidad * 100 )
      monto = (Math.round subtotal * pedido.Descuento / 100) / 100
    else
      monto = pedido.Descuento
    return monto

  @impuesto_monto: (pedido) =>
    monto = 0
    if pedido.Impuesto < 35
      subtotal = ( Math.round pedido.Precio * pedido.Cantidad * 100 )
      subtotal =   subtotal - ( Movimiento.descuento_monto(pedido) * 100 )
      monto    = ( Math.round subtotal * pedido.Impuesto / 100 ) / 100
    else
      monto =  pedido.Impuesto__c
    return monto

  @create_from_producto: (producto ) ->
    Movimiento.create
      Producto: producto.id
      Name: producto.Name
      Cantidad: 1
      Costo: producto.Costo
      Impuesto: producto.Impuesto
      Precio: producto.Precio
      Descuento: producto.Descuento
      
  @update_total: (pedido) =>
    pedido.SubTotal = Math.round(pedido.Precio * pedido.Cantidad * 100 ) / 100
    pedido.Total = pedido.SubTotal - Movimiento.descuento_monto(pedido) + Movimiento.impuesto_monto(pedido)

  @total: (pedidos) ->
    total = 0
    for pedido in pedidos
      Movimiento.update_total(pedido)
      total += pedido.Total
    parseInt(total*100)/100


module.exports = Pedido