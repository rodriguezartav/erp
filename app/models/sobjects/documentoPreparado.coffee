Spine = require('spine')

class DocumentoPreparado extends Spine.Model
  @configure "Documento", "Proveedor" , "Nombre_Contado" ,"Total" , "Saldo" , "CodigoExterno" , "Referencia" , "Observacion" , 
  "SubTotal" , "Descuento" , "Impuesto", "Fuente" , "Cliente" , "Plazo" , "FechaFacturacion","FechaVencimiento" ,
  "AplicarACuenta" , "Tipo_de_Documento" , "PagoEnRecibos", "IsContado"
  
  @extend Spine.Model.TransitoryModel
  @extend Spine.Model.Salesforce


  @avoidQueryList: [ "Referencia" , "Observacion" , "SubTotal" , "Descuento" , "Impuesto", "Fuente" ,
    "FechaFacturacion","FechaVencimiento" ,"AplicarACuenta","IsContado"]

  @queryFilter: (options ) =>
    return "" if !options
    filter =""
    filter = @queryFilterAddCondition(" Estado__c  = 'Preparado'"              , filter)
    filter

module.exports = DocumentoPreparado

