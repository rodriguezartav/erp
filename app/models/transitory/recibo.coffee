Spine = require('spine')

class Recibo extends Spine.Model
  @configure "Recibo" , "Cliente" , "Monto", "FormaPago" ,"FechaFormaPago" , "Observacion", "Referencia" , "CodigoExterno", 
    "DocumentosList" , "MontosList" , "ConsecutivosList" , "DocumentosLinks"
  
  
  @extend Spine.Model.SalesforceModel
  @extend Spine.Model.SalesforceAjax.Methods  

  @extend Spine.Model.TransitoryModel

  @autoQuery = false;

module.exports = Recibo

