require('lib/setup')
Spine = require('spine')
Documento = require("models/documento")
Saldo = require("models/socketModels/saldo")
Cliente = require("models/cliente")
Notas = require("apps/cuentasPorCobrar/notas")
Documento = require("models/documento")


class DocumentoLivecycle extends Spine.Controller
  className: "row-fluid"

  @departamento = "Credito y Cobro"
  @label = "Documentos"
  @icon = "icon-copy"

  elements:
    ".saldosList" : "saldosList"

  constructor: ->
    super
    @html require("views/apps/cuentasPorCobrar/documentoLivecycle/layout")(DocumentoLivecycle)
    @renderSaldos()

  renderSaldos: ->


    saldos = Saldo.groupBy Saldo.all() , "Cliente" , "Total"
    console.log saldos
    #saldos = _.groupBy saldos, (d) ->
     # return d.Cliente

    #console.log saldos
    #@saldosList.html require("views/apps/cuentasPorCobrar/documentoLivecycle/saldo")(saldos)

  reset: ->
    @release()
    @navigate "/apps"

module.exports = DocumentoLivecycle