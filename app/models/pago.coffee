Spine = require('spine')

class Pago extends Spine.Model
  @configure 'Pago', "Cliente", "Tipo" , "Documento",  "Monto" , "FormaPago"  , 
    "Referencia" , "Recibo","Fecha","Consecutivo"

  @extend Spine.Model.Salesforce
    

  @group_by_recibo: () ->
    pagos = Pago.all()
    recibos = (pago.Recibo for pago in pagos).unique()
    groups  = []
    for recibo in recibos
      pagos_in_recibo = []
      monto = 0
      consecutivos =[]
      for pago in pagos when pago.Recibo == recibo
        pagos_in_recibo.push pago
        consecutivos.push " #{pago.Consecutivo} -> #{pago.Monto.toMoney()} "
        monto += pago.Monto

      groups.push {Recibo: recibo , Fecha: pagos_in_recibo[0].Fecha , Consecutivos: consecutivos, Pagos: pagos_in_recibo , Cliente: pagos_in_recibo[0].Cliente , Monto: monto} if pagos_in_recibo.length > 0
    groups

  @queryFilter: (options ) =>
     return "" if !options
     filter =""
     filter = @queryFilterAddCondition(" Cliente__c = '#{options.cliente.id}' "       ,  filter)  if options.cliente
     filter = @queryFilterAddCondition(" Fecha__c = #{options.fecha} "     ,  filter)  if options.fecha
     filter

module.exports = Pago