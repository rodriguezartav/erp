Spine = require('spine')

class PagoProveedor extends Spine.Model
  @configure "PagoProveedor" , "Cuenta" , "FormaPago", "Referencia" ,"Observacion" , "Documentos", "Montos","TipoCambio"
  
  @extend Spine.Model.SalesforceModel
  @extend Spine.Model.SalesforceAjax.Methods

module.exports = PagoProveedor


#data       : @ajaxParameters( { name: "Tesoreria" , data: JSON.stringify( pagos: {Documentos: ["a","b"],Montos: [1,2] , Cuenta: "a" , FormaPago: "a" , Referencia: "a", Observacion: "a"} ) } )

