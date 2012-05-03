Spine = require('spine')

class FacturaPreparada extends Spine.Model
  @configure "Documento","Total" , "Saldo" , "CodigoExterno" , "Referencia" , "Observacion" , 
  "SubTotal" , "Descuento" , "Impuesto", "Fuente" , "Cliente" , "Plazo" , "FechaFacturacion" , "FechaVencimiento" ,
  "AplicarACuenta" , "Tipo_de_Documento" , "PagoEnRecibos", "IsContado"
  
  
  @extend Spine.Model.Salesforce
  @extend Spine.Model.SocketModel


  @avoidQueryList: [ "Referencia" , "Observacion" , "SubTotal" , "Descuento" , "Impuesto", "Fuente" ,
    "FechaFacturacion","FechaVencimiento" ,"AplicarACuenta","IsContado"]

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

