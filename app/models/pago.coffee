Spine = require('spine')

class Pago extends Spine.Model
  @configure 'Pago', "Cliente", "Tipo" , "Documento",  "Monto" , "FormaPago" , "FechaFormaPago" , "Referencia" , "CuentaBancaria" , "Recibo"


module.exports = Pago