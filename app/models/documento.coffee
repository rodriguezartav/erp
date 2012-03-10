Spine = require('spine')

class Documento extends Spine.Model
  @configure "Documento", "Total" , "Saldo" , "Consecutivo"

  @fetch_from_sf: (cliente , user) ->
    query = "Select Id , Total__c, Saldo__c , CodigoExterno__c from Documento__c  where Saldo__c != 0 and Cliente__c = '#{cliente.id}' "
    data = user.to_auth { query: query }
    $.ajax
      url: Spine.server + "/query"
      xhrFields: {withCredentials: true}
      type: "POST"
      data: data
      success: @on_update_success
      error: @on_update_error

  @from_sf: (obj) ->
    Documento.create 
      Total: obj.Total__c
      Saldo: obj.Saldo__c
      Consecutivo: obj.CodigoExterno__c
    
  @on_update_success: (raw_results) =>
    result_object = JSON.parse raw_results
    if result_object.success
      Documento.destroyAll()
      for result in result_object.results
        @from_sf result
      Documento.trigger "ajax_complete"
      Documento.trigger "refresh"
    else
      errors = JSON.parse raw_results
      Documento.trigger "ajax_error" , errors

       
  @on_update_error: (error) =>
    responseText  = error.responseText
    if responseText.length > 0
      errors = JSON.parse responseText
    else
      errors = {type:"LOCAL" , error: " Indefinido: Posiblemente Problema de Red", source: "Cliente" }
    Documento.trigger "ajax_error" , errors
  
module.exports = Documento

