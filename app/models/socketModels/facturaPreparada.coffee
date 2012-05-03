Spine = require('spine')

class FacturaPreparada extends Spine.Model
  @configure "Documento", "Total" , "CodigoExterno" , "Referencia" , "Observacion" , 
   "Cliente" ,  "FechaFacturacion"  , "Tipo_de_Documento" , "IsContado"
  
  
  @extend Spine.Model.Salesforce
  @extend Spine.Model.SocketModel

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

