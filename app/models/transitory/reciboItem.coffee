Spine = require('spine')

class ReciboItem extends Spine.Model
  @configure "ReciboItem" , "Total" , "Saldo" , "CodigoExterno" ,  "Cliente" , "Plazo" , "FechaFacturacion" , "FechaVencimiento" ,
    "Tipo_de_Documento" , "Restricciones" , "Monto" , "ReciboId" , "SaldoId"
 
  @extend Spine.Model.TransitoryModel


  @createFromSaldos: (saldos,recibo) ->
    items = []
    for saldo in saldos
      ri =
        Total: saldo.Total
        Saldo : saldo.Saldo
        CodigoExterno: recibo.CodigoExterno
        Cliente : saldo.Cliente
        Plazo: saldo.Plazo
        FechaVencimiento : saldo.FechaVencimiento
        FechaFacturacion : saldo.FechaFacturacion
        Tipo_de_Documento : saldo.Tipo_de_Documento
        Restricciones : saldo.Restricciones    
        Monto : 0
        ReciboId : recibo.CodigoExterno
        SaldoId : saldo.id
      items.push = ReciboItem.create(ri)
    items

module.exports = ReciboItem

