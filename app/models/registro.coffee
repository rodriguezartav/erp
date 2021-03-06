Spine = require('spine')

#'saldos por pagar','ventas credito','ventas contado','impuesto ventas','saldos','inventarios valor','inventarios unidad' , 'cobro'


class Registro extends Spine.Model
  @configure "Registro" , "Name" , "Monto" , "Descripcion" , "Tipo" , "Departamento" , "Fecha" , "Responsable"
 
  @extend Spine.Model.SalesforceModel
  @extend Spine.Model.SalesforceAjax.Methods


  getDia: ->
    date = new Date(Date.parse(@Fecha,"yyyy/MM/dd"));
    date.getDate()
    date.getDate()

  @refreshFromRest: (raw_results) =>
    results = JSON.stringify(raw_results)  
    results = @parseSalesforceJSON(results)
    @refresh(results)        

  @uniqueDepartamentos: ->
    departamentos = []
    for registro in Registro.all()
      departamentos.push registro.Departamento if departamentos.indexOf(registro.Departamento) == -1
    return departamentos

  @groupByDepartamento: (registros)  ->
    tiposMap = {}
    for registro in registros
      group = tiposMap[registro.Departamento] || {Registros: [] , Departamento: registro.Departamento, Monto: 0 }
      group.Monto += registro.Monto
      group.Registros.push registro
      tiposMap[registro.Departamento] = group
    tiposMap


  @groupByTipo: (registros)  ->
    tiposMap = {}
    for registro in registros
      group = tiposMap[registro.Tipo] || {Registros: [] , Departamento: registro.Departamento, Monto: 0 , Tipo: registro.Tipo}
      group.Monto += registro.Monto
      group.Registros.push registro
      tiposMap[registro.Tipo] = group

    tipos = []
    for index,value of tiposMap
      tipos.push value
    return tipos

  @queryFilter: (options) =>
    allowedTypes =  ''#@getFilterByProfile()
  
    return "" if !options
    filter = ""
    filter = @queryFilterAddCondition(" Tipo__c IN (#{allowedTypes}) "    , filter)   if allowedTypes.lenght > 0
    filter = @queryFilterAddCondition(" Fecha__c = TODAY "                , filter)   if options.today
    filter = @queryFilterAddCondition(" Dia__c = #{options.fecha} "       , filter)   if options.fecha
    filter = @queryOrderAddCondition(" order by Fecha__c "                , filter)
    
    
  @getAllowedDepartamentos: ->
      allowedTypes = []
      allowedTypes = ['saldos por pagar' , 'inventarios valor' , 'inventarios unidad' , 'cobro']  if Spine.session.hasPerfiles([ "Tesoreria" ])      
      allowedTypes = ['ventas contado','inventarios unidad'] if Spine.session.hasPerfiles([ "Ejecutivo Ventas" ])
      allowedTypes = ['ventas credito', 'ventas contado' , 'inventarios unidad'] if Spine.session.hasPerfiles([ "Encargado de Ventas" ])
      allowedTypes = ['saldos' , 'cobro' , 'ventas credito'] if Spine.session.hasPerfiles([ "Ejecutivo Credito" ])
      return allowedTypes
    
module.exports = Registro

