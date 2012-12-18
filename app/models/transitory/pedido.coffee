Spine = require('spine')

class Pedido extends Spine.Model
  @configure 'Pedido', "Cliente" ,  "Impuesto" , "Descuento" , "SubTotal" , "Total" , "Referencia" , "Observacion" , "IsContado" , "Transporte" ,
    "Orden" , "Especial" , "LastModifiedDate" , "Nombre" , "Identificacion"

  @extend Spine.Model.SalesforceModel
  @extend Spine.Model.SalesforceAjax.Methods  
  @extend Spine.Model.TransitoryModel
  
  
  
  
  
  
  updateFromPedidoItems: (items)  ->
    @Total = 0
    @Descuento =0
    @Impuesto = 0
    @SubTotal=0
    for item in items
      @SubTotal += item.SubTotal
      @Descuento += item.Descuento_Monto
      @Impuesto += item.Impuesto_Monto
      @Total += item.Total
      

module.exports = Pedido