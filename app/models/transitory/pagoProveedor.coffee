Spine = require('spine')

class PagoProveedor extends Spine.Model
  @configure "PagoProveedor" , "Cuenta" , "FormaPago", "Referencia" ,"Observacion" , "Items"
  
  @extend Spine.Model.Salesforce
  
  @insert: (pagoProveedor) ->
    $.ajax
      url        : Spine.server + "/rest"
      xhrFields  : {withCredentials: true}
      type       : "POST"
      data       : @ajaxParameters( { name: "Tesoreria" , data: JSON.stringify( pagoProveedor ) } )
      success    : @on_send_success
      error      : @on_send_error
  
module.exports = PagoProveedor

