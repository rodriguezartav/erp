require('lib/setup')
Spine = require('spine')
Documento = require("models/documento")

class ImprimirRecibo extends Spine.Controller
  constructor: ->
    super
    @html require("views/apps/procesos/documentosImpresion/layout")

module.exports = DocumentosImpresion