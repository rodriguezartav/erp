Spine = require('spine')

class PagoItem extends Spine.Model
  @configure "PagoItem" , "Cliente" , "Total" , "Tipo" , "Saldo" , "Consecutivo" , 
  "Documento" , "Tipo_de_Documento" , "Fecha" , "Monto","Recibo" , "FormaPago" , "Referencia"
 
  @extend Spine.Model.SalesforceModel
  @extend Spine.Model.SalesforceAjax.Methods

  @avoidInsertList = ["Saldo","Total","Consecutivo"] 
  @overrideName: "Pago"

  setTipo: ->
    if @Monto == @Saldo
      @Tipo = "PA"
    else
      @Tipo = "AB"

  @createFromSaldo: (saldo) ->
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


  @createFromDocumento: (saldo) ->
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

module.exports = PagoItem

