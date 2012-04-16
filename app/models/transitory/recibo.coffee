Spine = require('spine')

class Recibo extends Spine.Model
  @configure "Recibo" , "Cliente" , "Monto", "FormaPago" ,"FechaFormaPago" , "Observacion", "Referencia" , "CodigoExterno", 
    "DocumentosList" , "MontosList" , "ConsecutivosList" , "DocumentosLinks"
  
  
  @extend Spine.Model.Salesforce
  @extend Spine.Model.TransitoryModel

  @autoQuery = false;

module.exports = Recibo

