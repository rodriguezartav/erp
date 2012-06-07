Spine = require('spine')

class Saldo extends Spine.Model
  @configure "Saldo" , "Total" , "Saldo" , "Consecutivo" ,  "Cliente" , "Plazo" , "PlazoActual" , "FechaFacturacion" , "FechaVencimiento" ,
    "Tipo_de_Documento"  , "Autorizado" , "Observacion"

  @extend Spine.Model.Salesforce
  @extend Spine.Model.SocketModel

  #@autoPush= true
  @autoQueryTimeBased = true
  @autoQuery = true
  @overrideName = "Documento"

  @queryFilter: (options ) =>
    filter = ""
    filter = @queryFilterAddCondition(" IsContable__c = 'true' and IsContado__c = false"    , filter)
    filter = @queryFilterAddCondition(" Cliente__c = '#{options.cliente.id}' "              , filter)   if options.cliente
    filter = @queryFilterAddCondition(" Con_Saldo__c = 'true' "                             , filter)   if options.saldo
    filter = @queryFilterAddCondition(" Autorizado__c   = #{options.autorizado }"           ,  filter)  if options.autorizado
    filter = @queryFilterAddCondition(" Tipo_de_Documento__c IN (#{options.tipos}) "        ,  filter)  if options.tipos
    
    filter


  @overDraft: (cliente) ->
    saldos = Saldo.findAllByAttribute "Cliente" , cliente.id
    over60 = false
    for saldo in saldos
      over60 = true if saldo.PlazoActual > 60
    return over60

module.exports = Saldo

