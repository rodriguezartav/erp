require('lib/setup')
Spine = require('spine')
Documento = require("models/documento")
Cliente = require("models/cliente")
Producto = require("models/producto")
Saldo = require("models/socketModels/saldo")
CuentaPorPagar = require("models/transitory/cuentaPorPagar")
Proveedor = require("models/proveedor")

class CuentasLiveCycle extends Spine.Controller
  className: "row-fluid"

  @departamento = "Tesoreria"
  @label = "Cuentas por Pagar"
  @icon = "icon-ok-sign"

  elements:
    ".error" : "error"
    ".src_pendientes" : "src_pendientes" 
    ".src_calendarizados" : "src_calendarizados"
    ".src_paraPagar" : "src_paraPagar"
    ".src_pipeline" : "src_pipeline"
    ".txt_observacion" : "txt_observacion"
    ".src_list" : "src_list"
    ".lbl_totales":"lbl_totales"
    ".hiddenParaPagar" : "hiddenParaPagar"
    ".hiddenParaAplicar" : "hiddenParaAplicar"


  events:
    "click .cancel"   : "reset"
    "click .actionBtn"  : "onActionClick"
    "click .reload" : "reload"
    "click .item"  : "onItemClick"
    "click .btn_aplicar" : "onAplicarGenerado"
    "click .hiddenParaPagar" : "onGenerar"

  constructor: ->
    super
    @html require("views/apps/cuentasPorPagar/cuentasLiveCycle/layout")(CuentasLiveCycle)
    @selectedTipo = "Local"
    @reload()

  reload: (fromClick) =>
    @selectedTipo = null if fromClick
    CuentaPorPagar.destroyAll()
    CuentaPorPagar.ajax().query({ forWorkflow: true , orderFechaVencimiento: true , tipo: @selectedTipo } ,  afterSuccess: @render )

  render: =>
    totales=[0,0,0]
    calendarizados= []
    paraPagar = []
    @paraGenerar = []
    pendientes = []
    semana = {}
    
    for cuenta in CuentaPorPagar.all()
      cuenta.Estado = "Calendarizado" if cuenta.Estado == "Para Pagar"

      if cuenta.Estado == 'Pendiente'
        pendientes.push cuenta
        totales[2]+= cuenta.Saldo

      else if cuenta.Estado == "Calendarizado"
        itemSemana = semana[cuenta.getFechaPagoProgramado().weeksFromToday()] || 0
        itemSemana += cuenta.Saldo
        semana[cuenta.getFechaPagoProgramado().weeksFromToday()] = itemSemana
        
        if( cuenta.getFechaPagoProgramado().getTime() <= new Date().getTime() and cuenta.Saldo > 0 )
          paraPagar.push cuenta
          @paraGenerar.push cuenta if !cuenta.Enviado
          totales[0]+= cuenta.Saldo
        else
          totales[1]+= cuenta.Saldo
          calendarizados.push cuenta

    @src_list.html "<li><h5>No hay pedidos en la lista</h5></li>"

    @renderByWeek(@src_pendientes,pendientes , "getFechaVencimiento" , "smartItemPendiente")
    @renderByWeek(@src_calendarizados,calendarizados, "getFechaPagoProgramado" ,"smartItemCalendarizado")
    @renderByWeek(@src_paraPagar,paraPagar, "getFechaPagoProgramado" ,"smartItemParaPagar")

    @hiddenParaPagar.attr "href" , @generateArchive()

    @src_pipeline.html "<li class='header'>Pagos por Semana</li>"

    for index,value of semana
      @src_pipeline.append require("views/apps/cuentasPorPagar/cuentasLiveCycle/smartItemPipeline")(semana: index , saldo: value)

    @lbl_totales.each (index,lbl) =>
      lbl = $(lbl)
      lbl.html totales.pop().toMoney()

    pickers = @el.find('.txtFecha').datepicker({autoclose: true})
    pickers.on("change",@onInputChange)

    if !@toggleRendered then @renderToggle()


  renderToggle: =>
    $('#t1').toggleButtons
      width: 250,
      label:
        enabled: "Internacional"
        disabled: "Local"
      onChange: ($el, status, e) =>
        @selectedTipo = if status then "Internacional" else "Local"
        @reload()
        @toggleRendered = true
        return true

  renderByWeek: (src , list , dateFnc , template) ->
    src.empty()
    return if list.length == 0
    thisWeek = null
    lastWeek = null
    counter = 0
    for item in list
      thisWeek = item[dateFnc]().weeksFromToday()
      if thisWeek != lastWeek
        src.append "<li class='header'>#{ if thisWeek < 0 then 'En ' + Math.abs(thisWeek) + " Semanas" else "Atrasado"}</li>" 
        
      lastWeek = thisWeek
      src.append require("views/apps/cuentasPorPagar/cuentasLiveCycle/#{template}")(item)

  generateArchive: =>
    csv = ''
    for cuenta in @paraGenerar
      proveedor = Proveedor.find cuenta.Proveedor
      csv+= "#{proveedor.tipoCedulaNumeric()}," 
      csv+= "#{proveedor.Cedula or ''},"
      csv+= "#{proveedor.Name},"
      csv+= "#{proveedor.CuentaCliente or ''},"
      csv+= "#{cuenta.Saldo},"
      csv+= "#{proveedor.Moneda or 0},"
      csv+= "Pago Rodco,"
      csv+= "0,"
      csv+= "integracionbct@rodcocr.com,"
      csv+= "#{cuenta.id}\n "
    
    @hiddenParaPagar.hide() if @paraGenerar.length == 0
    return "data:application/octet-stream,#{csv}"

  onItemClick: (e) =>
    target = $(e.target)
    target = target.parent() until target.attr "data-id"
    details = target.find(".details")
    status = details.is(":visible")
    @el.find(".details").hide()
    target.find(".details").show() if !status

  onInputChange: (e) =>
    target = $(e.target)
    newEstado = target.attr("data-newEstado")
    @cuenta = CuentaPorPagar.find(target.attr("data-id"))
    @cuenta.FechaPagoProgramado = target.val()
    @cuenta.Estado = newEstado
    @update(@cuenta)
    return false;

  onActionClick: (e) =>
    target = $(e.target)
    estado = target.attr("data-newEstado")
    @cuenta = CuentaPorPagar.find(target.attr("data-id"))
    @cuenta.Estado = estado
    @update(@cuenta);
    return false;
    
  update: (data) =>
    Spine.trigger "show_lightbox" , "update" , data , @aprobarSuccess
    return false;

  onGenerar: =>
    @hiddenParaAplicar.show()

  onAplicarGenerado: =>
    cuenta.Enviado = true for cuenta in @paraGenerar
    cuentasSf = CuentaPorPagar.salesforceFormat(@paraGenerar,true)

    data =
      class: CuentaPorPagar
      restRoute: "Tesoreria"
      restMethod: "POST"
      restData:   cuentas: cuentasSf

    Spine.trigger "show_lightbox" , "rest" , data , @reload

  aprobarSuccess: (sucess,results) =>
    @cuenta.save()
    @render()
    @notify()
    @cuenta=null

  notify: =>
    Spine.socketManager.pushToFeed("Actualizamos la Cuenta a #{@cuenta.Estado}")

  reset: ->
    @paraGenerar = []
    @cuenta=null;
    @release()
    @navigate "/apps"

module.exports = CuentasLiveCycle