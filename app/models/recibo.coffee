Spine = require('spine')

class Recibo extends Spine.Model
  @configure "Recibo" , "Cliente" , "Monto", "FormaPago" ,"FechaFormaPago" , "Observacion", "Referencia" , "CodigoExterno", 
    "DocumentosList","MontosList","ConsecutivosList","DocumentosLinks" 
  
  
  # "CodigoUnico" ,"Cliente" , "Documentos" , "Encargado" ,  "Monto" , "FormaPago" , "FechaFormaPago" , "ReferenciaFormaPago" , "Observacion" , 
#    "Conciliado","ConciliadoPor" , "ReferenciaDeposito" , "FechaEnvio", "DepositarEnCuenta" ,
 #   "Depositado" , "DepositadoPor" , "NumeroTransaccion" , "FechaDeposito" ,
  #  "Aprobado","AprobadoPor"
  
  ##emitir recibis
  # primero se digita e imprime el recibo, de cualquier manera; Vendedor, En Sitio, etc. Si no se puede imprimir, se hace mano usando el numero de referencia del sistema

  ##depositar Recibos
  # luego se revisa en tesoria, recibos vrs documentos liquidables; se asigna un numero interno de deposito y se enviar a depositar
  # tesoreria puede pedir al vendedor que deposite sus recibos, tome una foto al deposito y lo envie por correo
  # los clientes pueden hacer y reportar sus propios de depositos y transferencias; proporcionan el numero de deposito
  
  ##conciliarRecibos
  # cuando tesoreria recibe el Numero de deposito, concilia con el banco, marca las recibos como depositados y les asigna el numero de deposito

  ##aprobarRecibos
  # si lo recibos cumplen con las politicas de credibilidad (ej, cheques creibles  ), Tesoreria da su aprobacion Final
  # se le pasan los recibos y resto de documentacion fisica a Credito y Cobro, para que sean aplicados los pagos en las cuentas de los clientes

  # cuando se aprueba un recibo, se hace un movimiento contable de la cuenta facturas por cobrar del cliente vrs depositos en bancos
  
  # cuando se hace un pago se hace un movimiento en el auxiliar del cliente
  
  # cualquier diferencia o error, se nota en el cierre diario: total de saldos contables vrs el total de saldos auxiliar...
  
  @extend Spine.Model.Salesforce
  @extend Spine.Model.NSyncModel

  createLists: ->
    #montosList = montosList.substring(0,montosList.length-1)
    #documentosList = documentosList.substring(0,documentosList.length-1)
    #consecutivosList = consecutivosList.substring(0,consecutivosList.length-1)
    #object.DocumentosList = documentosList
    #documentosList += "#{src.id},"
    #montosList += "#{item.Monto},"
    #consecutivosList += "#{item.Consecutivo},"
  #  documentosLinks += '<a href="/' + item.Documento + '">' + item.Consecutivo + '</a><br/>'
    
    
    #object.MontosList = montosList
    #object.ConsecutivosList = consecutivosList
    #object.DocumentosLinks = documentosLinks
    
    
  beforeInsert: ->
    @createLists()
    @ReciboItems = JSON.stringify @ReciboItems

module.exports = Recibo

