Spine = require('spine')

class Saldo extends Spine.Model
  @configure "Saldo" , "Total" , "Saldo" , "Consecutivo" ,  "Cliente" , "Plazo" , "PlazoActual" , "FechaFacturacion" , "FechaVencimiento" ,
    "Tipo_de_Documento"  , "Autorizado" , "Observacion"

  @extend Spine.Model.Salesforce
  @extend Spine.Model.SocketModel

  @autoQueryTimeBased = true
  @overrideName = "Documento"  

  #Turned On only for certain profiles in SecurityManager
  @autoQuery = false
  @allowCreate = false

  @onQuerySuccess: ->
    saldos = Saldo.select (saldo) ->
      return true if saldo.Saldo == 0
    return alert("Debe usa la opcion Actualizar Ahora") if saldos.length > 500
    for saldo in saldos
      saldo.destroy()

  @queryFilter: (options ) =>
    filter = ""
    filter = @queryFilterAddCondition(" IsContable__c = 'true' and IsContado__c = false"    , filter)
    filter = @queryFilterAddCondition(" Cliente__c = '#{options.cliente.id}' "              , filter)   if options.cliente
    filter = @queryFilterAddCondition(" Con_Saldo__c = 'true' "                             , filter)   if options.saldo
    filter = @queryFilterAddCondition(" Autorizado__c   = #{options.autorizado }"           , filter)   if options.autorizado
    filter = @queryFilterAddCondition(" Tipo_de_Documento__c IN (#{options.tipos}) "        , filter)   if options.tipos
    filter

  PlazoReal: =>
    date = Date.parse @FechaFacturacion 
    date = new Date(date)
    plazo = date.days_from_now(date)

  @overDraft: (cliente) ->
    saldos = Saldo.select (item) ->
      overd = false
      overd = true if item.Cliente == cliente.id and item.Tipo_de_Documento == "FA" and item.PlazoActual > 63
      #console.log item.Tipo_de_Documento + " :: " + item.PlazoActual if item.Cliente == cliente.id 
      return overd;
      
    return if saldos.length > 0 then true else false

module.exports = Saldo

