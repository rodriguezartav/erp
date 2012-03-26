require('lib/setup')
Spine = require('spine')
Movimientos = require("controllers/movimientos")
Documento = require("models/documento")
Cliente = require("models/cliente")
Producto = require("models/producto")
Movimiento = require("models/movimiento")
Cierre = require("models/cierre")
User = require("models/user")


class CierresContable extends Spine.Controller
  className: "row"

  @departamento = "Contabilidad"
  @label = "Cierre Contable"
  
  elements:
    "#txt_dia_inicial" : "txt_dia_inicial"
    "#txt_mes_inicial" : "txt_mes_inicial"
    "#txt_ano_inicial" : "txt_ano_inicial"
    "#ventas" : "ventas"
    "#inventarios" : "inventarios"
    "#saldos" : "saldos"
    "#pagos" : "pagos"
    "#proveedores" : "proveedores"
    "#txt_dia_final" : "txt_dia_final"
    "#txt_mes_final" : "txt_mes_final"
    "#txt_ano_final" : "txt_ano_final"
    ".error" : "error"
    ".save" : "send"
    ".loading" : "loading"

  events:
    "click .save" : "send"

  constructor: ->
    super
    @error.hide()
    Cierre.query(fecha: new Date().toSimple() )
    Cierre.bind "query_success" , @onCierreFetchComplete
    @html require("views/apps/contables/cierresContable/loading")(@documento)
    Cierre.bind "query_error" , =>
      @loading.hide()
      @error.show()
      alert "Ocurrio un error, intente de nuevo dado refrescar."

  onCierreFetchComplete: =>
    @cierre = Cierre.first()
    if @cierre.ultimoCierre
      @cierre.loadCierreAnteriorAndTest()
      @renderCierre()
    else
      Spine.trigger "show_lightbox" , "cierreManual" , @cierre , @onCierreManualComplete
      
  onCierreManualComplete: =>
    @cierre.loadCierreAnteriorAndTest()
    @renderCierre()

  renderCierre: =>
    @html require("views/apps/contables/cierresContable/layout")(@documento)

    src ="views/apps/contables/cierresContable/item"
    @ventas.append require(src)(label: "Contado" , value: @cierre.ventasContado)
    @ventas.append require(src)(label: "Credito" , value: @cierre.ventasCredito)
    @ventas.append require(src)(label: "Notas Credito" , value: @cierre.ventasNotaCredito)
    @ventas.append require(src)(label: "Notas Debito" , value: @cierre.ventasNotaDebito)
    @ventas.append require(src)(label: "Impuestos" , value: @cierre.ventasImpuesto)
    @ventas.append require(src)(label: "Descuentos" , value: @cierre.ventasDescuento)
    @ventas.append require(src)(label: "Periodo" , value: @cierre.ventasFinal)
    @ventas.append require(src)(label: "Prueba" , value: @cierre.ventasValor)


    @inventarios.append require(src)(label: "Inicial" , value: @cierre.inventariosInicial)
    @inventarios.append require(src)(label: "Ventas" , value: @cierre.inventariosVenta)
    @inventarios.append require(src)(label: "Entradas" , value: @cierre.inventariosEntrada)
    @inventarios.append require(src)(label: "Compras" , value: @cierre.inventariosCompra)
    @inventarios.append require(src)(label: "Salidas" , value: @cierre.inventariosSalida)
    @inventarios.append require(src)(label: "Devol." , value: @cierre.inventariosDevolucion)
    @inventarios.append require(src)(label: "Sistema" , value: @cierre.inventariosValor)
    @inventarios.append require(src)(label: "Calculado" , value: @cierre.inventariosFinal)
    
    @saldos.append require(src)(label: "Inicial" , value: @cierre.saldosInicial)
    @saldos.append require(src)(label: "Facturas" , value: @cierre.saldosFactura)
    @saldos.append require(src)(label: "Notas Credito" , value: @cierre.saldosNotaCredito)
    @saldos.append require(src)(label: "Notas Debito" , value: @cierre.saldosNotaDebito)
    @saldos.append require(src)(label: "Pagos" , value: @cierre.pagosValor)
    @saldos.append require(src)(label: "Sistema" , value: @cierre.saldosValor)
    @saldos.append require(src)(label: "Calculado" , value: @cierre.saldosFinal)
    
    @pagos.append require(src)(label: "Inicial" , value: @cierre.pagosInicial)
    @pagos.append require(src)(label: "Facturas" , value: @cierre.pagosFactura)
    @pagos.append require(src)(label: "Nota Credito" , value: @cierre.pagosNotaCredito)
    @pagos.append require(src)(label: "Nota Debito" , value: @cierre.pagosNotaDebito)
    @pagos.append require(src)(label: "Sistema" , value: @cierre.pagosValor)
    @pagos.append require(src)(label: "Calculado" , value: @cierre.pagosFinal)
    
    @proveedores.append require(src)(label: "Inicial" , value: @cierre.saldosProveedorInicial)
    @proveedores.append require(src)(label: "Compras" , value: @cierre.ventasProveedor)
    @proveedores.append require(src)(label: "Pagos" , value: @cierre.pagosProveedor)
    @proveedores.append require(src)(label: "Sistema" , value: @cierre.saldosProveedor)
    @proveedores.append require(src)(label: "Calculado" , value: @cierre.saldosProveedorFinal)
    
    @cierre.save()

  #####
  # ACTIONS
  #####
  
  send: (e) =>
    Spine.trigger "show_lightbox" , "sendCierre" , @cierre , @after_send

  after_send: =>
    @send.hide()
 
  reset: =>
    @release()
    @navigate "/apps"
   

module.exports = CierresContable