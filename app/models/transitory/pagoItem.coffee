Spine = require('spine')

class PagoItem extends Spine.Model
  @configure "PagoItem" , "Cliente" , "Total" , "Tipo" , "Saldo" , "Consecutivo" , 
  "Documento" , "Tipo_de_Documento" , "Fecha" , "Monto","Recibo" , "FormaPago" , "Referencia" , "UserStamp" , "UsedInPago"
 
  @extend Spine.Model.SalesforceModel
  @extend Spine.Model.SalesforceAjax.Methods
  @extend Spine.Model.TransitoryModel
  
  @avoidInsertList = ["Saldo","Total","Consecutivo" , "UsedInPago","UserStamp"] 
  @overrideName: "Pago"

  setTipo: ->
    if @Monto == @Saldo
      @Tipo = "PA"
    else
      @Tipo = "AB"

  @itemsInPago: (pago) ->
    PagoItem.findAllByAttribute("UserStamp", pago.UserStamp )

  @deleteItemsInPago: (pago) =>
    items = @itemsInPago(pago)
    for item in items
      item.destroy()

  @saldoExists: (saldo) =>
    item = PagoItem.findByAttribute "Consecutivo" , saldo.Consecutivo
    return item || null

  @createFromSaldo: (saldo,pedido) ->
    PagoItem.create
      Total: saldo.Total
      Saldo : saldo.Saldo
      Consecutivo: saldo.Consecutivo
      Cliente : saldo.Cliente
      Documento: saldo.id
      Fecha : Date.now()
      PlazoActual: saldo.PlazoActual
      Tipo_de_Documento : saldo.Tipo_de_Documento
      Monto : 0
      UsedInPago: false
      UserStamp: pedido.UserStamp
        

  @createFromDocumento: (saldo, pedido) ->
    PagoItem.create
      Total: saldo.Total
      Saldo : saldo.Saldo
      Consecutivo: saldo.Consecutivo
      Cliente : saldo.Cliente
      Documento: saldo.id
      Fecha : Date.now()
      PlazoActual: saldo.PlazoActual
      Tipo_de_Documento : saldo.Tipo_de_Documento
      Monto : 0
      UsedInPago: false
      UserStamp: pedido.UserStamp
      

module.exports = PagoItem

