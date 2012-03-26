Spine = require('spine')

class Pago extends Spine.Model
  @configure 'Pago', "Tipo",  "Monto" , "Documento",  "Monto" , "FormaPago" , "Referencia" , "CuentaBancaria" , "Recibo"
  @extend Spine.Model.Salesforce

  @format_for_server: ->  
    results = []
    pago = Pago.all()
    for pago in pagos
      temp = 
        Documento__c:         pago.Documento
        Referencia__c:        pago.Referencia
        Observacion__c:       pago.Observacion
        Tipo__c:              pago.Tipo
        Monto__c:             pago.Monto
        FormaPago__c:         pago.FormaPago
        Cuenta_Bancaria__c:   pago.CuentaBancaria
        Recibo__c:            pago.Recibo
      results.push temp
    results

  @send_to_server: (user) =>
    data = user.to_auth { type: "Pago__c" , items: JSON.stringify( @format_for_server() )  }
    $.ajax
      url        :  Spine.server + "/save/bulk"
      type       :  "POST"
      data       :  data
      success    :  Movimiento.on_send_success
      error      :  Movimiento.on_send_error

  @on_send_success: (raw_results) =>
    results = JSON.parse raw_results
    Movimiento.trigger "fetch_complete" , results

  @on_send_error: (error) =>
    responseText = error.responseText
    if responseText.length > 0
      errors = JSON.parse responseText
    else
      errors = { type:"LOCAL" , error: " Indefinido: Posiblemente Problema de Red", source: "Pedido" }
    Movimiento.trigger "fetch_error" , errors



module.exports = Pago