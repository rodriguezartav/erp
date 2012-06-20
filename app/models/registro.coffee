Spine = require('spine')

class Registro extends Spine.Model
  @configure "Registro" , "Name" , "Monto" , "Descripcion" , "Tipo" , "Departamento" , "Fecha" , "Responsable"
 
  @extend Spine.Model.Salesforce

  @uniqueDepartamentos: ->
    departamentos = []
    for registro in Registro.all()
      departamentos.push registro.Departamento if departamentos.indexOf(registro.Departamento) == -1
    return departamentos

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
    return "" if !options
    filter = ""
    filter = @queryFilterAddCondition(" Fecha__c = TODAY "                             , filter)   if options.today
    filter = @queryFilterAddCondition(" Dia__c = #{options.fecha} "                  , filter)   if options.fecha
    filter = @queryOrderAddCondition(" order by Fecha__c "               , filter)
    
    
module.exports = Registro

