Spine = require('spine')

class Cuenta extends Spine.Model
  @configure "Codigo" , "Name" 

  @fetch_from_sf: (user) ->
    query = "Select Id , Name , Codigo__c from Cuenta__c where tipo__c = 'Bancaria'"
    data = user.to_auth { query: query }
    $.ajax
      url: Spine.server + "/query"
      xhrFields: {withCredentials: true}
      type: "POST"
      data: data
      success: @on_fetch_success
      error: @on_fetch_error

  @from_sf: (obj) ->
    Cuenta.create 
      id: obj.Id
      Name: obj.Name
      Codigo: obj.Codigo__c

  @on_fetch_success: (raw_results) =>
    result_object = JSON.parse raw_results
    if result_object.success
      for result in result_object.results
        @from_sf result
      Cuenta.trigger "ajax_complete"
      Cuenta.trigger "refresh"
    else
      errors = JSON.parse raw_results
      Documento.trigger "ajax_error" , errors

  @on_fetch_error: (error) =>
    responseText  = error.responseText
    if responseText.length > 0
      errors = JSON.parse responseText
    else
      errors = {type:"LOCAL" , error: " Indefinido: Posiblemente Problema de Red", source: "Cliente" }
    Documento.trigger "ajax_error" , errors

module.exports = Cuenta

