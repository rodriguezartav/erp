Spine = require('spine')

class Producto extends Spine.Model
  @configure 'Producto', 'Name', 'CodigoExterno', 'InventarioActual', 'Precio_Distribuidor' , 'DescuentoMaximo' ,'Familia', 
  'Impuesto' , "Activo" , "Costo" , "CostoAnterior"
  @extend Spine.Model.Salesforce
  @extend Spine.Model.SelectableModel
  @extend Spine.Model.NSyncModel

  @autoReQuery = true;

  @queryFilter: (options ) =>
    return "" if !options
    filter =""
    @queryFilterAddCondition(" Precio_Distribuidor__c > 0 ", filter) if options.withPrecio
    filter += " order by CodigoExterno__c "
    filter
    
  Ratio: ->
    r = (@Venta / @Meta)
    r = 1 if r >= 1
    r = 0.1 if r <= 0 or isNaN(r)
    r*=100

  Disponible: ->
    @Minimo = @Minimo || 0
    venta_restante = @Meta - @Venta
    venta_restante = 0 if venta_restante < 0
    color = "black"
    if @Cantidad == 0
      color = "white"      
    else if @Cantidad - venta_restante > @Minimo
      color = "green"
    else if @Cantidad - venta_restante <= 0
      color = "red"
    else if @Cantidad <= @Minimo
      color = "yellow"
    else if @Cantidad > @Minimo
      color = "brown"

  
    return color

  @map_by_familia: (productos) ->
    familias = (producto.Familia for producto in productos).unique()
    groups  = []
    for familia in familias
      ratio = 0
      producto_in_familia = []
      for producto in productos when producto.Familia == familia
        producto_in_familia.push producto
        ratio+= producto.Ratio()
      groups.push {familia: familia , productos: producto_in_familia , ratio: ratio / producto_in_familia.length}
    groups

module.exports = Producto