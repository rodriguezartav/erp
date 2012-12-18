Spine = require('spine')

class PagoItem extends Spine.Model
  @configure "PagoItem" , "Cliente" , "Total" , "Tipo" , "Saldo" , "Consecutivo" , "PagoId" ,
  "Documento" , "Tipo_de_Documento" , "Fecha" , "Monto","Recibo" , "FormaPago" , "Referencia"  , "UsedInPago"
 
  @extend Spine.Model.SalesforceModel
  @extend Spine.Model.SalesforceAjax.Methods
  @extend Spine.Model.TransitoryModel
  
  @avoidInsertList = ["Saldo","Total","Consecutivo" , "UsedInPago" , "PagoId"] 
  @overrideName: "Pago"

  setTipo: ->
    if @Monto == @Saldo
      @Tipo = "PA"
    else
      @Tipo = "AB"

  @itemsInPago: (pago) ->
    PagoItem.findAllByAttribute("PagoId", pago.id )

  @deleteItemsInPago: (pago) =>
    items = @itemsInPago(pago)
    for item in items
      item.destroy()

  @saldoExists: (saldo) =>
    item = PagoItem.findByAttribute "Consecutivo" , saldo.Consecutivo
    return item || null

  @createFromSaldo: (saldo,pago) ->
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
      PagoId: pago.id

  @createFromDocumento: (saldo, pago) ->
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
      PagoId: pago.id

module.exports = PagoItem
