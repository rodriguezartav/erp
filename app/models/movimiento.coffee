Spine = require('spine')

class Movimiento extends Spine.Model
  @configure 'Movimiento', "Tipo", "Nombre_Contado",  "Producto" , "ProductoCantidad" , "ProductoPrecio" , "Impuesto" , 
  "Descuento" , "SubTotal" , "Total" , "ProductoCosto" , "Referencia","Observacion","Cliente","CodigoExterno"
  
  @extend Spine.Model.Salesforce
   
  @avoidInsertList = ["Total"] 
   
  @queryFilter: (options ) =>
    return "" if !options
    filter =""
    filter = @queryFilterAddCondition(" Fecha__c   = LAST_#{options.diasAtras}_DAYS " , filter) if options.diasAtras
    filter = @queryFilterAddCondition(" Tipo__c IN (#{options.tipos}) "               , filter) if options.tipos
    filter = @queryFilterAddCondition(" Cliente__c = '#{options.cliente.id}' "        , filter) if options.cliente
    filter
 
   
  @descuento_monto: (movimiento) =>
    subtotal = (Math.round movimiento.ProductoPrecio * movimiento.ProductoCantidad * 100 )
    monto = (Math.round subtotal * movimiento.Descuento / 100) / 100
    
  @impuesto_monto: (movimiento) =>
    subtotal = ( Math.round movimiento.ProductoPrecio * movimiento.ProductoCantidad * 100 )
    subtotal = subtotal - ( @descuento_monto(movimiento) * 100 )
    monto    = ( Math.round subtotal * movimiento.Impuesto / 100 ) / 100

  @update_total: (movimiento) =>
    movimiento.SubTotal = Math.round(movimiento.ProductoPrecio * movimiento.ProductoCantidad * 100 ) / 100
    movimiento.Total = movimiento.SubTotal - Movimiento.descuento_monto(movimiento) + Movimiento.impuesto_monto(movimiento)

  @create_from_producto: (producto ) ->
    Movimiento.create
      Producto: producto.id
      Name: producto.Name
      Cantidad: 1
      ProductoCosto: producto.Costo
      Impuesto: producto.Impuesto
      ProductoPrecio: producto.Precio
      Descuento: producto.Descuento

  @total: (movimientos) ->
    total = 0
    for movimiento in movimientos
      Movimiento.update_total(movimiento)
      total += movimiento.Total
    parseInt(total*100)/100

module.exports = Movimiento