require('lib/setup')
Spine = require('spine')
Documento = require("models/documento")
Cliente = require("models/cliente")
Producto = require("models/producto")
PedidoPreparado = require("models/socketModels/pedidoPreparado")
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
    ".src_pagados" : "src_pagados"
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
    totales=[0,0,0,0]
    calendarizados= []
    paraPagar = []
    pendientes = []
    pagados = []
    
    for cuenta in CuentaPorPagar.all()
      if cuenta.Estado == 'Pendiente'
        pendientes.push cuenta
        totales[3]+= cuenta.Saldo
      else if cuenta.Estado == "Calendarizado"
        if( cuenta.getFechaPagoProgramado().getTime() <= new Date().getTime() )
          paraPagar.push cuenta
          totales[1]+= cuenta.Saldo
        else
          totales[2]+= cuenta.Saldo
          calendarizados.push cuenta
      else if cuenta.Estado == "Para Pagar"
        paraPagar.push cuenta
        totales[1]+= cuenta.Saldo
      else if cuenta.Estado == "Preparado" or cuenta.Estado == "Entregado"
        pagados.push cuenta
        totales[0]+= cuenta.Total

    pendientes.sort (a,b) ->
      return a.getFechaVencimiento().getTime() - b.getFechaVencimiento().getTime()

    calendarizados.sort (a,b) ->
      return a.getFechaPagoProgramado().getTime() - b.getFechaPagoProgramado().getTime()

    paraPagar.sort (a,b) ->
      return a.getFechaPagoProgramado().getTime() - b.getFechaPagoProgramado().getTime()

    pagados.sort (a,b) ->
      return b.getFecha_de_Pago().getTime() - a.getFecha_de_Pago().getTime()
 
    @src_list.html "<li><h5>No hay pedidos en la lista</h5></li>"
    @src_pendientes.html require("views/apps/cuentasPorPagar/cuentasLiveCycle/smartItemPendiente")( pendientes ) if pendientes.length > 0
    @src_calendarizados.html require("views/apps/cuentasPorPagar/cuentasLiveCycle/smartItemCalendarizado")( calendarizados ) if calendarizados.length > 0
    @src_paraPagar.html require("views/apps/cuentasPorPagar/cuentasLiveCycle/smartItemParaPagar")( paraPagar ) if paraPagar.length > 0
    @src_pagados.html require("views/apps/cuentasPorPagar/cuentasLiveCycle/smartItemPagado")( pagados ) if pagados.length > 0

    @lbl_totales.each (index,lbl) =>
      lbl = $(lbl)
      lbl.html totales.pop().toMoney()

    pickers = @el.find('.txtFecha').datepicker({autoclose: true})
    pickers.on("change",@onInputChange)

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
    @cuenta=null
    @render()
    @notify()


  notify: =>
    #cliente = Cliente.find @cliente
    #verb = if @aprobar == 1 then "Aprobe" else "Archive"
    #Spine.socketManager.pushToFeed("#{verb} un pedido de #{clinte.Name}") 

    #Spine.throttle ->
     # Spine.socketManager.pushToProfile("Ejecutivo Ventas" , "#{verb} varios pedidos, pueden proceder a revisarlos.")
    #, 15000

  reset: ->
    @cuenta=null;
    PedidoPreparado.unbind "push_success" , @renderPedidos
    @el.find('.popable').popover("hide")
    $('.popover').hide()
    @release()
    @navigate "/apps"

module.exports = CuentasLiveCycle