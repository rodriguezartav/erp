require('lib/setup')
Spine = require('spine')
CuentaPorPagar = require("models/transitory/cuentaPorPagar")

class FlujoDePago extends Spine.Controller
  className: "row-fluid"

  @departamento = "Tesoreria"
  @label = "Flujo de Pagos"
  @icon = "icon-road"

  elements:
    ".srcCuentas" : "srcCuentas" 
    ".error"      : "error"
    ".lblTotal"  : "lblTotal"
    ".saldo"      : "saldos"

  events:
    "click .cancel"   : "reset"
    "click .send"     : "onSend"
    "click .reload"   : "reload"
    "click .saldo"    : "onSaldoClick"

  constructor: ->
    super
    @html require("views/apps/cuentasPorPagar/cuentasPorPagarFlujo/layout")(FlujoDePago)
    @error.hide()
    CuentaPorPagar.bind "insert_error" , @onPagoProgramadoUpdateError
    @reload()

  reload: ->
    CuentaPorPagar.destroyAll()
    CuentaPorPagar.ajax().query({ estado: "'Pendiente','Calendarizado'" , orderFechaVencimiento: true } ,  afterSuccess: @renderCuentas )        

  renderCuentas: =>
    cuentas = CuentaPorPagar.all()
    @srcCuentas.html require("views/apps/cuentasPorPagar/cuentasPorPagarFlujo/item")(cuentas)
    pickers =  @el.find('.txtFecha').datepicker({autoclose: true})
    pickers.on("change",@onInputChange)
    @el.find('.info_popover').popover({placement: "top"})

  onInputChange: (e) =>
    @error.hide()
    target = $(e.target)
    fechaPagoProgramado = new Date(e.timeStamp)
    #move to otherFun
    cuenta = CuentaPorPagar.find(target.attr("data-id"))
    cuenta.FechaPagoProgramado = target.val() #fechaPagoProgramado.to_salesforce_date()
    cuenta.Estado = "Calendarizado"
    cuenta.FlagedToSave = true;
    cuenta.save()    
    
  onSaldoClick: (e) =>
    target = $(e.target)
    total = 0
    saldos = @el.find(".saldo")
    for saldo in saldos
      s = $(saldo)
      monto = parseFloat s.attr "data-saldo"
      total += monto if s.hasClass("active") and s.attr("data-id") != target.attr("data-id")
    if !target.hasClass("active")
      total += parseFloat(target.attr("data-saldo")) 
      target.addClass "btn-info"

      #move to otherFun
      cuenta = CuentaPorPagar.find(target.attr("data-id"))
      cuenta.Estado = "Para Aprobar"
      cuenta.FlagedToSave = true;
      cuenta.save()

    else
      target.removeClass "btn-info"
            
    @lblTotal.html total.toMoney()
      
  
  beforeSend: =>
    saldos = @el.find(".saldo")
    for saldo in saldos
      s = $(saldo)
      if s.hasClass("active")
        cuenta = CuentaPorPagar.find(s.attr("data-id"))
        cuenta.Estado = "Para Aprobar"
        cuenta.FechaPagoProgramado = new Date().to_salesforce_date() if !cuenta.FechaPagoProgramado
        cuenta.FlagedToSave = true;
        cuenta.save()
      
  onSend: =>
    @beforeSend()
    cuentas = CuentaPorPagar.all()
    cuentasSf = CuentaPorPagar.salesforceFormat(cuentas,true)
    
    data =
      class: CuentaPorPagar
      restRoute: "Tesoreria"
      restMethod: "POST"
      restData:   cuentas: cuentasSf

    Spine.trigger "show_lightbox" , "rest" , data , @saveSuccess

  saveSuccess: =>
    Spine.socketManager.pushToProfile("Tesoreria" , "He ingresado CXP al Flujo")
    window.open("https://na7.salesforce.com/00OA0000004WuVF")
    @reset()
    
  reset: ->
    @release()
    @navigate "/apps"

module.exports = FlujoDePago