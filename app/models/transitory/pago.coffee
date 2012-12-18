Spine = require('spine')

class Pago extends Spine.Model
  @configure "Pago" , "Cliente" , "Monto", "FormaPago" ,"Fecha" ,  "Referencia" , "Recibo" , "Codigo"
  
  @extend Spine.Model.SalesforceModel
  @extend Spine.Model.SalesforceAjax.Methods  
  @extend Spine.Model.TransitoryModel

module.exports = Pago

