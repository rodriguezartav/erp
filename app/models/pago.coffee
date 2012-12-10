Spine = require('spine')

class Pago extends Spine.Model
  @configure 'Pago', "Cliente", "Tipo" , "Documento" ,  "Monto" , "FormaPago"  , "MontoPendiente" ,
    "Referencia" , "Recibo" , "Fecha", "Consecutivo" , "Estado" , "Aprobado" , "Contabilizado" , "Standby" , 
     "CreatedById" , "AprobadoPor"  , "Custodio" , "EstadoNumerico"

  @extend Spine.Model.SalesforceModel
  @extend Spine.Model.SalesforceAjax.Methods    

  @group_by_recibo: (pagos = Pago.all()) ->

    recibos = (pago.Recibo for pago in pagos).unique()
    groups  = []
    for recibo in recibos
      pagos_in_recibo = []
      monto = 0
      montoPendiente = 0
      consecutivos =[]
      for pago in pagos when pago.Recibo == recibo
        pagos_in_recibo.push pago
        consecutivos.push pago.Consecutivo
        monto += pago.Monto
        montoPendiente += pago.MontoPendiente

      groups.push {Recibo: recibo , CreatedByid: pagos_in_recibo[0].CreatedByid ,  FormaPago: pagos_in_recibo[0].FormaPago , Fecha: pagos_in_recibo[0].Fecha , Consecutivos: consecutivos, Pagos: pagos_in_recibo , Cliente: pagos_in_recibo[0].Cliente , Monto: monto , MontoPendiente: montoPendiente , Custodio: pagos_in_recibo[0].Custodio } if pagos_in_recibo.length > 0
    groups

  @queryFilter: (options ) =>
     return "" if !options
     filter = ""
     filter = @queryFilterAddCondition(" Cliente__c = '#{options.cliente.id}' "       ,  filter)  if options.cliente
     filter = @queryFilterAddCondition(" Fecha__c = #{options.fecha} "     ,  filter)  if options.fecha
     filter = @queryFilterAddCondition(" EstadoNumerico__c != 5 or CreatedDate = TODAY"     ,  filter)  if options.livecycle and !options.search
     filter = @queryFilterAddCondition(" Recibo__c = '#{options.search}' or Referencia__c = '#{options.search}' "     ,  filter)  if options.search
     #filter = @queryFilterAddCondition(" DepositadoFecha__c = LAST_N_DAYS:7 and CreatedById = '#{depositadosUsuario}'"     ,  filter)  if options.depositadosUsuario != null
     
     filter

module.exports = Pago