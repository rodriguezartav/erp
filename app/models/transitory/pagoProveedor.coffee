Spine = require('spine')

class PagoProveedor extends Spine.Model
  @configure "PagoProveedor" , "Cuenta" , "FormaPago", "Referencia" ,"Observacion" , "Documentos", "Montos","TipoCambio"
  
  @extend Spine.Model.Salesforce

module.exports = PagoProveedor


#data       : @ajaxParameters( { name: "Tesoreria" , data: JSON.stringify( pagos: {Documentos: ["a","b"],Montos: [1,2] , Cuenta: "a" , FormaPago: "a" , Referencia: "a", Observacion: "a"} ) } )

