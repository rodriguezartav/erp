Spine = require('spine')

class PagoProveedor extends Spine.Model
  @configure "PagoProveedor" , "Cuenta" , "FormaPago", "Referencia" ,"Observacion" , "Documentos", "Montos","TipoCambio"
  
  @extend Spine.Model.Salesforce
  
  @insert: (pagoProveedor) ->
    pagoProveedor.id= null
    $.ajax
      url        : Spine.server + "/rest"
      xhrFields  : {withCredentials: true}
      type       : "PUT"
      data       : @ajaxParameters( { name: "Tesoreria" , data: JSON.stringify( pagos: pagoProveedor ) } )
      success    : @on_send_success
      error      : @on_send_error
  
module.exports = PagoProveedor


#data       : @ajaxParameters( { name: "Tesoreria" , data: JSON.stringify( pagos: {Documentos: ["a","b"],Montos: [1,2] , Cuenta: "a" , FormaPago: "a" , Referencia: "a", Observacion: "a"} ) } )

