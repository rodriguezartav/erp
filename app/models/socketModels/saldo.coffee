Spine = require('spine')

class Saldo extends Spine.Model
  @configure "Saldo" , "Total" , "Saldo" , "Consecutivo" ,  "Cliente" , "Plazo" , "PlazoActual" , "FechaFacturacion" , "FechaVencimiento" ,
    "Tipo_de_Documento"  , "Autorizado" , "Observacion" , "LastModifiedDate"

  @extend Spine.Model.SalesforceModel
  @extend Spine.Model.SalesforceAjax.Methods
  @extend Spine.Model.SocketModel

  @autoQueryTimeBased = true
  @overrideName = "Documento"  

  #Turned On only for certain profiles in SecurityManager
  @autoQuery = false
  @allowCreate = false

  @queryFilter: (options = {}) =>
    filter = ""
    filter = @queryFilterAddCondition(" IsContable__c = 'true' and IsContado__c = false"    , filter)
    filter = @queryFilterAddCondition(" Cliente__c = '#{options.cliente.id}' "              , filter)   if options.cliente
    filter = @queryFilterAddCondition(" Cliente__c = '#{options.clienteId}' "              , filter)   if options.clienteId
    filter = @queryFilterAddCondition(" Con_Saldo__c = 'true' "                             , filter)   if options.saldo or Saldo.initQuery
    filter = @queryFilterAddCondition(" Autorizado__c   = #{options.autorizado }"           , filter)   if options.autorizado == false or options.autorizado == true
    filter = @queryFilterAddCondition(" Tipo_de_Documento__c IN (#{options.tipos}) "        , filter)   if options.tipos
    filter = @queryOrderAddCondition(" order by LastModifiedDate desc limit 3000 "                   , filter)  
    filter

  PlazoReal: =>
    date = Date.parse @FechaFacturacion 
    date = new Date(date)
    plazo = date.days_from_now(date)

  @groupBy: (list , value , sum) ->
    map = {}
    for item in list
      itemValue = item[value]
      mapped = map[itemValue] or {items: [] , sum: 0}
      mapped.items.push item
      mapped.sum += item[sum]
      map[itemValue] = mapped

  @overDraft: (cliente) ->
    saldos = Saldo.select (item) ->
      overd = false
      overd = true if item.Cliente == cliente.id and item.Tipo_de_Documento == "FA" and item.PlazoActual > 63
      #console.log item.Tipo_de_Documento + " :: " + item.PlazoActual if item.Cliente == cliente.id 
      return overd;
      
    return if saldos.length > 0 then true else false

module.exports = Saldo

