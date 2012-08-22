Spine = require('spine')

class FacturaPreparada extends Spine.Model
  @configure "Documento", "Total" , "Consecutivo" , "Referencia" , "Observacion" , 
   "Cliente" ,  "FechaFacturacion"  , "Tipo_de_Documento" , "IsContado" , "Estado"

  @extend Spine.Model.SalesforceModel
  @extend Spine.Model.SalesforceAjax.Methods  

  @extend Spine.Model.SocketModel

  @autoQueryTimeBased   :   false
  #Turned On only for certain profiles in SecurityManager
  @autoQuery = false
  @destroyBeforeRefresh = true;


  @beforeSocketUpdate: (results) ->
    for result in results
      return false if result.Estado__c != "Impreso" and result.Estado__c == "Preparado"
    return true    

  @filterImpresion: =>
    results = []
    for doc in DocumentoPreparado.all()
      results.push doc if doc.Tipo_de_Documento == "FA" or doc.Estado == "Preparado"
    results
    

  @filterNotas: =>
    results = []
    for doc in DocumentoPreparado.all()
      results.push doc if doc.Tipo_de_Documento == "NC" or doc.Tipo_de_Documento == 'ND'
    results

  @queryFilter: (options ) =>
    filter =""
    filter = @queryFilterAddCondition(" Estado__c  = 'Preparado'" , filter)
    filter = @queryFilterAddCondition(" Tipo_de_Documento__c  = 'FA'" , filter) 
    filter

module.exports = FacturaPreparada

