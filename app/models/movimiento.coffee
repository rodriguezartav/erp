Spine = require('spine')

class Movimiento extends Spine.Model
  @configure 'Movimiento', "Tipo", "Nombre_Contado",  "Producto" , "ProductoCantidad" , "ProductoPrecio" , "ProductoCosto" , 
   "Impuesto" , "Descuento" , "SubTotal" , "Total" , "Referencia" , "Observacion" , "Cliente" ,
   "CodigoExterno" , "Descuento_Unitario" , "Impuesto_Unitario" ,"Plazo", "Proveedor" , "ProductoCantidadPendiente"
  
  @extend Spine.Model.SalesforceModel
  @extend Spine.Model.SalesforceAjax.Methods
   
  @avoidInsertList = ["Total","Descuento_Unitario","Impuesto_Unitario", "CodigoExterno"] 
  #Adeed proveedor to list, because error in Devolucion 
  @avoidQueryList = ["Plazo","Proveedor","ProductoCosto"]
   
  @queryFilter: (options ) =>
    return "" if !options
    filter =""
    filter = @queryFilterAddCondition(" Fecha__c   = LAST_N_DAYS:#{options.diasAtras} " , filter) if options.diasAtras
    filter = @queryFilterAddCondition(" Tipo__c IN (#{options.tipos}) "               , filter) if options.tipos
    filter = @queryFilterAddCondition(" Cliente__c = '#{options.cliente.id}' "        , filter) if options.cliente
    filter = @queryFilterAddCondition(" IsAplicado__c = false  and Tipo__c IN ('EN','SA','CO') and Fecha__c   = LAST_N_DAYS:5 "        , filter) if options.livecycle
    filter
 
  @create_from_producto: (producto, cantidad = 1 ) ->
    movimiento = Movimiento.create
      Producto: producto.id
      Name: producto.Name
      Cantidad: 1
      ProductoCosto: producto.Costo if producto.Costo
      Impuesto: producto.Impuesto
      ProductoPrecio: producto.Precio
      Descuento: producto.Descuento
      ProductoCantidad: cantidad
    movimiento.updateSubTotal()
    movimiento.applyDescuento()
    movimiento.applyImpuesto()
    movimiento.updateTotal()
    movimiento.save()

  @group_by_boleta: (movimientos = Movimiento.all()) ->

    boletas = (movimiento.Referencia for movimiento in movimientos).unique()
    groups  = []
    for boleta in boletas
      movimientos_in_boleta = []
      for movimiento in movimientos when movimiento.Referencia == boleta
        movimientos_in_boleta.push movimiento

      groups.push {Boleta: boleta, Procucto: movimientos_in_boleta[0].Producto ,  Tipo: movimientos_in_boleta[0].Tipo , Movimientos: movimientos_in_boleta } if movimientos_in_boleta.length > 0
    groups

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