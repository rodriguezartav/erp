require('lib/setup')
Spine = require('spine')
Documento = require("models/documento")
Cliente = require("models/cliente")
Producto = require("models/producto")
Documento = require("models/documento")
Pago = require("models/pago")
Deposito = require("models/deposito")

class DepositosLivecycle extends Spine.Controller
  className: "row-fluid"

  @departamento = "Tesoreria"
  @label = "Administracion Depositos"
  @icon = "icon-ok-sign"

  elements:
    ".src_contado"          :  "contado"
    ".src_valores"          :  "valores"
    ".src_transferencias"   :  "transferencias"
    ".src_depositos"        :  "depositos"
    
  events:
    "click .reload" : "reload"
    "click .btn_deposito" : "onCreateDeposito"
    "click .btn_create_deposit" : "createDeposit"

  constructor: ->
    super
    @html require("views/apps/cuentasPorPagar/depositosLivecycle/layout")(DepositosLivecycle)
    Deposito.bind "create destroy" , @renderDepositos
    @reload()

  reload: (fromClick) =>
    @renderStep = 0
    Documento.destroyAll()
    Pago.destroyAll()
    Documento.ajax().query { contadoSinEntregar: true } ,  afterSuccess: @renderSwitch
    Pago.ajax().query      { deposito: true           } ,  afterSuccess: @renderSwitch

  renderSwitch: =>
    @renderStep++;
    @render() if @renderStep == 2

  render: =>
    @contado.html require("views/apps/cuentasPorPagar/depositosLivecycle/sectionContado")(documentos: Documento.all())

    pagos = Pago.select (item) =>
      if item.FormaPago == 'Efectivo' || item.FormaPago == 'Cheque' then return true else return false
    @valores.html require("views/apps/cuentasPorPagar/depositosLivecycle/sectionValores")(pagos: Pago.group_by_recibo( pagos ) )

    transferencias = Pago.select (item) =>
      if item.FormaPago == 'Transferencia' || item.FormaPago == 'Deposito' then return true else return false
    @transferencias.html require("views/apps/cuentasPorPagar/depositosLivecycle/sectionTransferencias")(pagos: Pago.group_by_recibo( transferencias ) )


  renderDepositos: =>
    @depositos.html require("views/apps/cuentasPorPagar/depositosLivecycle/deposito")(Deposito.all())
  
  onCreateDeposito: =>
    Deposito.create()

  createDeposit: (e) =>
    target = $(e.target)
    Deposito.create(Name: target.data("name") , Monto: target.data("monto"))
    



  reset: ->
    @release()
    Deposito.unbind "create destroy" , @renderDepositos
    @navigate "/apps"

module.exports = DepositosLivecycle