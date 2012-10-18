Spine = require('spine')

class PedidoItem extends Spine.Model
  @configure 'PedidoItem' , "Cliente" , "Producto" , "Cantidad" , "Precio" , "Impuesto_Monto" , "Impuesto", "Descuento" , 
  "Descuento_Monto" ,"SubTotal" , "Total" , "Referencia" , "Observacion" , "Fuente" , "Referencia" , "IsContado",
  "Nombre", "Telefono", "Email" , "Identificacion" , "Orden" , "Transporte" , "Especial" , "LastModifiedDate"
    
  @extend Spine.Model.SalesforceModel
  @extend Spine.Model.SalesforceAjax.Methods
  @extend Spine.Model.TransitoryModel

  @overrideName = "Oportunidad"

  @avoidInsertList = ["Total","Descuento_Monto","Impuesto_Monto", "SubTotal" , "LastModifiedDate"] 

  @createFromProducto: (producto ) ->
    pedido = PedidoItem.create
      Producto: producto.id
      Name: producto.Name
      Cantidad: 1
      Costo: producto.Costo
      Impuesto: producto.Impuesto
      Precio: producto.Precio_Distribuidor
      Descuento: producto.DescuentoMaximo
    pedido.updateSubTotal()
    pedido.applyDescuento()
    pedido.applyImpuesto()
    pedido.updateTotal()
    pedido.save()

  @itemsInPedido: (pedido) ->
    PedidoItem.findAllByAttribute("Referencia", pedido.Referencia )

  @deleteItemsInPedido: (pedido) =>
    items = @itemsInPedido(pedido)
    for item in items
      item.destroy()

  @isProductoInList: (list, producto) ->
    for item  in list
      return true if item.Producto.id == producto.id
    return false

  @isProductoInPedido: (producto,referencia) ->
    items  = PedidoItem.findAllByAttribute( "Referencia" , referencia )
    for item  in items
      return true if item.Producto.id == producto.id
    return false

  isEspecial: (producto) =>
    @Especial = true if @Precio < producto.Precio_Distribuidor
    @Especial = true if @Descuento > producto.DescuentoMaximo
    @Especial = true if @Impuesto != producto.Impuesto
    @save()

  updateSubTotal: ->
    @SubTotal = Math.round(@Precio * @Cantidad * 100 ) / 100
    @save()

  applyDescuento:  ->
    @Descuento_Monto = Math.round( @Descuento * @SubTotal) / 100
    @save()

  applyImpuesto:  ->
    @Impuesto_Monto = Math.round( @Impuesto * (@SubTotal- @Descuento_Monto) ) / 100
    @save()

  updateTotal:  =>
    @updateSubTotal()
    @Total = @SubTotal - @Descuento_Monto + @Impuesto_Monto
    @save()
    

module.exports = PedidoItem