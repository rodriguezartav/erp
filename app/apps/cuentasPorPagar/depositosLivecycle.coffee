require('lib/setup')
Spine = require('spine')
Documento = require("models/documento")
Cliente = require("models/cliente")
Producto = require("models/producto")
Documento = require("models/documento")
Pago = require("models/pago")

class DepositosLivecycle extends Spine.Controller
  className: "row-fluid"

  @departamento = "Tesoreria"
  @label = "Administracion Depositos"
  @icon = "icon-ok-sign"

  constructor: ->
    super
    @html require("views/apps/cuentasPorPagar/depositosLivecycle/layout")(DepositosLivecycle)
    @selectedTipo = "Local"
    @reload()

  reload: (fromClick) =>
    @renderStep = 0
    Documento.ajax().query( { contadoSinEntregar: true } ,  afterSuccess: @renderStep )
    Pago.ajax().query(      { deposito: true           } ,  afterSuccess: @renderStep )

  renderStep: =>
    @renderStep +=1
    @render() if @renderStep == 2
    
  render: =>
    console.log "rendering"

  reset: ->
    @release()
    @navigate "/apps"

module.exports = DepositosLivecycle