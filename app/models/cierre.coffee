Spine = require('spine')

class Cierre extends Spine.Model
  @configure "Cierre" , "fecha", "ventasCredito","ventasContado","ventasNotaCredito","ventasNotaDebito","ventasImpuesto", "ventasDescuento", "ventasExcento" , "ventasValor", 
    "pagosFactura" , "pagosNotaCredito" , "pagosNotaDebito",  "pagosValor",
    "inventariosDevolucion" , "inventariosCompra", "inventariosEntrada", "inventariosSalida","inventariosVenta","inventariosValor",
    "saldosFactura", "saldosNotaCredito", "saldosNotaDebito", "saldosValor"  , 
    "pagosProveedor", "ventasProveedor","saldosProveedor",
    "inventariosInicial" , "ventasInicial" , "saldosInicial","pagosInicial" ,  "saldosProveedorInicial",
    "inventariosFinal" , "ventasFinal" , "saldosFinal", "pagosFinal" , "saldosProveedorFinal" , 
    "ultimoCierre"

  parseFromDate: =>
    @fecha = "#{@ano}-#{@mes}-#{@dia}"

  parseUltimoCierre: ->
    if(@ultimoCierre.length == 0)
      @ultimoCierre = null
    else
      @ultimoCierre = JSON.parse @ultimoCierre[0].cierre
    return @save()

  loadCierreAnteriorAndTest: ->
    @inventariosInicial = @ultimoCierre.inventariosFinal
    @ventasInicial = @ultimoCierre.ventasFinal
    @saldosInicial = @ultimoCierre.saldosFinal
    @pagosInicial =  @ultimoCierre.pagosFinal
    @saldosProveedorInicial =  @ultimoCierre.saldosProveedorFinal
    @inventariosFinal = @inventariosInicial + @inventariosCompra - @inventariosEntrada + @inventariosDevolucion - @inventariosSalida - @inventariosVenta
    @ventasFinal = (@ventasContado + @ventasCredito + @ventasNotaDebito - @ventasNotaCredito + @ventasImpuesto - @ventasDescuento ) || 0
    @saldosFinal = (@saldosInicial + @saldosFactura + @saldosNotaDebito + @saldosNotaCredito) || 0
    @saldosProveedorFinal = (@saldosProveedorInicial + @ventasProveedor + @pagosProveedor) || 0
    @pagosFinal = 0
    @save()

  @ajaxParameters: (params) ->
     params.instance_url= Spine.session.instance_url
     params.token= Spine.session.token
     params.host= Spine.session.host
     params

  @query: (options) ->
    $.ajax
      url: Spine.server + "/cierre"
      xhrFields: {withCredentials: true}
      type: "GET"
      data: @ajaxParameters(options)
      success: @on_query_success
      error: @on_query_error

  @on_query_success: (raw_results) =>
    results = JSON.parse raw_results
    results.ultimoCierre = if results.ultimoCierre.length > 0 then JSON.parse(results.ultimoCierre[0].cierre) else null
    cierre =  Cierre.create results
    console.log cierre
    @trigger "query_success"

  @on_query_error: (error) =>
    @trigger "query_error" , error

  @insert: (cierre) =>
    cierre.ultimoCierre = null
    data = @ajaxParameters( cierre: JSON.stringify(cierre) )
    $.ajax
      url: Spine.server + "/cierre"
      xhrFields: {withCredentials: true}
      type: "POST"
      data: data
      success: @on_insert_success
      error: @on_insert_error

module.exports = Cierre

