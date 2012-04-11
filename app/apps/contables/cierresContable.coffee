require('lib/setup')
Spine = require('spine')
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
    "click .cancel" : "reset"

  constructor: ->
    super
    @error.hide()
    Cierre.destroyAll()
    Cierre.query(fecha: new Date().toSimple() )
    Cierre.bind "query_success" , @onCierreFetchComplete
    Cierre.bind "query_error" , @onCierreError
    @html require("views/apps/contables/cierresContable/loading")(@documento)
    

  onCierreError: =>
      @loading.hide()
      @error.show()
      alert "Ocurrio un error, intente de nuevo dado refrescar."

  onCierreFetchComplete: =>
    @cierre = Cierre.last()
    @renderCierre()
      
  onCierreManualComplete: =>
    @cierre.loadCierreAnteriorAndTest()
    @renderCierre()

  renderCierre: =>
    @html require("views/apps/contables/cierresContable/layout")(@documento)

    src ="views/apps/contables/cierresContable/item"
    @ventas.append require(src)(label: "Inicial" , value: @cierre.VentasInicial)
    @ventas.append require(src)(label: "Contado" , value: @cierre.VentasContado)
    @ventas.append require(src)(label: "Credito" , value: @cierre.VentasCredito)
    @ventas.append require(src)(label: "Notas Credito" , value: @cierre.VentasNotaCredito)
    @ventas.append require(src)(label: "Notas Debito" , value: @cierre.VentasNotaDebito)
    @ventas.append require(src)(label: "Impuestos" , value: @cierre.VentasImpuesto)
    @ventas.append require(src)(label: "Descuentos" , value: @cierre.VentasDescuento)
    @ventas.append require(src)(label: "Periodo" , value: @cierre.VentasValor)
    @ventas.append require(src)(label: "Final" , value: @cierre.VentasFinal)

    @inventarios.append require(src)(label: "Inicial" , value: @cierre.InventariosInicial)
    @inventarios.append require(src)(label: "Ventas" , value: @cierre.InventariosVenta)
    @inventarios.append require(src)(label: "Entradas" , value: @cierre.InventariosEntrada)
    @inventarios.append require(src)(label: "Compras" , value: @cierre.InventariosCompra)
    @inventarios.append require(src)(label: "Salidas" , value: @cierre.InventariosSalida)
    @inventarios.append require(src)(label: "Devol." , value: @cierre.InventariosDevolucion)
    @inventarios.append require(src)(label: "Final" , value: @cierre.InventariosFinal)
    @inventarios.append require(src)(label: "Comprobacion" , value: @cierre.InventariosValor)

    
    @saldos.append require(src)(label: "Inicial" , value: @cierre.SaldosInicial)
    @saldos.append require(src)(label: "Facturas" , value: @cierre.SaldosFactura)
    @saldos.append require(src)(label: "Notas Credito" , value: @cierre.SaldosNotaCredito)
    @saldos.append require(src)(label: "Notas Debito" , value: @cierre.SaldosNotaDebito)
    @saldos.append require(src)(label: "Final" , value: @cierre.SaldosFinal)
    @saldos.append require(src)(label: "Comprobacion" , value: @cierre.SaldosValor)

    @pagos.append require(src)(label: "Inicial" , value: @cierre.PagosInicial)
    @pagos.append require(src)(label: "Facturas" , value: @cierre.PagosFactura)
    @pagos.append require(src)(label: "Nota Credito" , value: @cierre.PagosNotaCredito)
    @pagos.append require(src)(label: "Nota Debito" , value: @cierre.PagosNotaDebito)
    @pagos.append require(src)(label: "Final" , value: @cierre.PagosFinal)
    @pagos.append require(src)(label: "Comprobacion" , value: @cierre.PagosValor)
    
    @proveedores.append require(src)(label: "Inicial" , value: @cierre.SaldosProveedorInicial)
    @proveedores.append require(src)(label: "Compras" , value: @cierre.VentasProveedor)
    @proveedores.append require(src)(label: "Pagos" , value: @cierre.PagosProveedor)
    @proveedores.append require(src)(label: "Final" , value: @cierre.SaldosProveedorFinal)
    @proveedores.append require(src)(label: "Comprobacion" , value: @cierre.SaldosProveedor)
    
    @cierre.save()

  #####
  # ACTIONS
  #####
  
  send: (e) =>
    Spine.trigger "show_lightbox" , "sendCierre" , @cierre , @after_send

  after_send: =>
    @send.hide()
 
  reset: =>
    Cierre.unbind "query_success" , @onCierreFetchComplete
    Cierre.unbind "query_error" , @onCierreError
    
    @release()
    @navigate "/apps"
   

module.exports = CierresContable