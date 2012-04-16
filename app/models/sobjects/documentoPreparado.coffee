Spine = require('spine')

class DocumentoPreparado extends Spine.Model
  @configure "Documento","Total" , "Saldo" , "CodigoExterno" , "Referencia" , "Observacion" , 
  "SubTotal" , "Descuento" , "Impuesto", "Fuente" , "Cliente" , "Plazo" , "FechaFacturacion" , "FechaVencimiento" ,
  "AplicarACuenta" , "Tipo_de_Documento" , "PagoEnRecibos", "IsContado"
  
  @extend Spine.Model.TransitoryModel
  @extend Spine.Model.Salesforce

  @avoidQueryList: [ "Referencia" , "Observacion" , "SubTotal" , "Descuento" , "Impuesto", "Fuente" ,
    "FechaFacturacion","FechaVencimiento" ,"AplicarACuenta","IsContado"]

  @filterNotas: =>
    results = []
    for doc in DocumentoPreparado.all()
      results.push doc if doc.Tipo_de_Documento == "NC" or doc.Tipo_de_Documento == 'ND'
    results

  @queryFilter: (options ) =>
    return "" if !options
    filter =""
    filter = @queryFilterAddCondition(" Estado__c  = 'Preparado'" , filter)
    filter = @queryFilterAddCondition(" Tipo_de_Documento  = '#{options.tipo}'" , filter) if filter.tipo

    filter

module.exports = DocumentoPreparado

