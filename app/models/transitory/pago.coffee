Spine = require('spine')

class Pago extends Spine.Model
  @configure "Pago" , "Cliente" , "Monto", "FormaPago" ,"Fecha" ,  "Referencia" , "Recibo" , "Codigo"
  
  
module.exports = Pago

