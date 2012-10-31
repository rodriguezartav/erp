require('lib/setup')
Spine = require('spine')
Documento = require("models/documento")
Cliente = require("models/cliente")
Producto = require("models/producto")
Saldo = require("models/socketModels/saldo")
CuentaPorPagar = require("models/transitory/cuentaPorPagar")


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
    

  events:
    "click .cancel"   : "reset"
    "click .actionBtn"  : "onActionClick"
    "click .reload" : "reload"
    "click .item"  : "onItemClick"

  constructor: ->
    super
    @html require("views/apps/cuentasPorPagar/cuentasLiveCycle/layout")(CuentasLiveCycle)
    @render()
    @reload()

  reload: ->
    CuentaPorPagar.destroyAll()
    CuentaPorPagar.ajax().query({ forWorkflow: true , orderFechaVencimiento: true } ,  afterSuccess: @render )        

  render: =>
    totales=[0,0,0]
    calendarizados= []
    paraPagar = []
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
        
        if( cuenta.getFechaPagoProgramado().getTime() <= new Date().getTime() )
          paraPagar.push cuenta
          totales[0]+= cuenta.Saldo
        else
          totales[1]+= cuenta.Saldo
          calendarizados.push cuenta

    @src_list.html "<li><h5>No hay pedidos en la lista</h5></li>"
    #@src_pendientes.html require("views/apps/cuentasPorPagar/cuentasLiveCycle/smartItemPendiente")( pendientes ) if pendientes.length > 0
    
    @renderByWeek(@src_pendientes,pendientes , "getFechaVencimiento" , "smartItemPendiente")
    @renderByWeek(@src_calendarizados,calendarizados, "getFechaPagoProgramado" ,"smartItemCalendarizado")
    @renderByWeek(@src_paraPagar,paraPagar, "getFechaPagoProgramado" ,"smartItemParaPagar")
    
    @src_pipeline.html "<li class='header'>Pagos por Semana</li>"
    
    for index,value of semana
      @src_pipeline.append require("views/apps/cuentasPorPagar/cuentasLiveCycle/smartItemPipeline")(semana: index , saldo: value)

    @lbl_totales.each (index,lbl) =>
      lbl = $(lbl)
      lbl.html totales.pop().toMoney()

    pickers = @el.find('.txtFecha').datepicker({autoclose: true})
    pickers.on("change",@onInputChange)

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
    

  
  renderPipeline: (src) =>
    #for cuenta in CuentaPorPagar.filterAllByAttribute("Estado" , "Calendarizado")
      
    

  onItemClick: (e) =>
    target = $(e.target)
    target = target.parent() until target.attr "data-id"
    details = target.find(".details")
    status = details.is(":visible")
    @el.find(".details").hide()
    target.find(".details").show() if !status

  onInputChange: (e) =>
    target = $(e.target)
    fechaPagoProgramado = new Date(e.timeStamp)
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

  aprobarSuccess: (sucess,results) =>
    @cuenta.save()
    @render()
    @notify()
    @cuenta=null

  notify: =>
    Spine.socketManager.pushToFeed("Actualizamos la Cuenta a #{@cuenta.Estado}")
  

  reset: ->
    @cuenta=null;
    PedidoPreparado.unbind "push_success" , @renderPedidos
    @el.find('.popable').popover("hide")
    $('.popover').hide()
    @release()
    @navigate "/apps"

module.exports = CuentasLiveCycle