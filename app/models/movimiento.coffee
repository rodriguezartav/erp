Spine = require('spine')

class Movimiento extends Spine.Model
  @configure 'Movimiento', "Tipo", "Nombre_Contado",  "Producto" , "ProductoCantidad" , "ProductoPrecio" , "Impuesto" , 
  "Descuento" , "SubTotal" , "Total" , "ProductoCosto" , "Referencia","Observacion","Cliente",
  "CodigoExterno","Descuento_Unitario","Impuesto_Unitario" , "Proveedor"
  
  @extend Spine.Model.Salesforce
   
  @avoidInsertList = ["Total","Descuento_Unitario","Impuesto_Unitario", "CodigoExterno"] 
   
  @queryFilter: (options ) =>
    return "" if !options
    filter =""
    filter = @queryFilterAddCondition(" Fecha__c   = LAST_#{options.diasAtras}_DAYS " , filter) if options.diasAtras
    filter = @queryFilterAddCondition(" Tipo__c IN (#{options.tipos}) "               , filter) if options.tipos
    filter = @queryFilterAddCondition(" Cliente__c = '#{options.cliente.id}' "        , filter) if options.cliente
    filter
 
  @create_from_producto: (producto ) ->
    movimiento = Movimiento.create
      Producto: producto.id
      Name: producto.Name
      Cantidad: 1
      ProductoCosto: producto.Costo
      Impuesto: producto.Impuesto
      ProductoPrecio: producto.Precio
      Descuento: producto.Descuento
    movimiento.updateSubTotal()
    movimiento.applyDescuento()
    movimiento.applyImpuesto()
    movimiento.updateTotal()
    movimiento.save()

  updateSubTotal: ->
    @SubTotal = Math.round(@ProductoPrecio * @ProductoCantidad * 100 ) / 100

  applyDescuento:  ->
    @Descuento = Math.round( @Descuento_Unitario * @SubTotal) / 100

  applyImpuesto:  ->
    @Impuesto = Math.round( @Impuesto_Unitario * (@SubTotal- @Descuento) ) / 100

  updateTotal:  ->
    @updateSubTotal()
    @Total = @SubTotal - @Descuento + @Impuesto


module.exports = Movimiento