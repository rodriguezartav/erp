Spine = require('spine')

class Cierre extends Spine.Model
  @configure "Cierre" , "Fecha", "VentasCredito","VentasContado","VentasNotaCredito","VentasNotaDebito","VentasImpuesto", "VentasDescuento", "VentasExcento" , "VentasValor", 
    "PagosFactura" , "PagosNotaCredito" , "PagosNotaDebito",  "PagosValor",
    "InventariosDevolucion" , "InventariosCompra", "InventariosEntrada", "InventariosSalida","InventariosVenta","InventariosValor",
    "SaldosFactura", "SaldosNotaCredito", "SaldosNotaDebito", "SaldosValor"  , 
    "PagosProveedor", "VentasProveedor", "SaldosProveedor",
    "InventariosInicial" , "VentasInicial" , "SaldosInicial" , "PagosInicial" ,  "SaldosProveedorInicial",
    "InventariosFinal" , "VentasFinal" , "SaldosFinal", "PagosFinal" , "SaldosProveedorFinal" , 

    @extend Spine.Model.Salesforce

  @query: (options) ->
    options.name = "Cierre"
    $.ajax
      url: Spine.server + "/rest"
      xhrFields: {withCredentials: true}
      type: "POST"
      data: @ajaxParameters(options)
      success: @on_query_success
      error: @on_query_error

module.exports = Cierre

