require('lib/setup')
Spine = require('spine')


class DocumentoLiveCycle extends Spine.Controller
  className: "row-fluid"

  @departamento = "Credito y Cobro"
  @label = "Documentos"
  @icon = "icon-retweet"

  elements:
    ".panel"               :   "panel"
    ".create"              :   "create"    
    ".movimientos_list"    :   "movimientos_list"
    ".list_pendientes"     :   "list_pendientes"
    ".list_aplicados"      :   "list_aplicados"

  events:
    "click .btn_create"       : "onCreate"
    "click .item" :       "onItemClick"
    "click input" : "onInputClick"
    "click .reload"  : "reload"
    "click .btn_bulk" : "onBulkAction"
    "change .costoInput" : "onInputChange"
    "change .observacionInput": "onObservacionChange"

  constructor: ->
    super
    @html require("views/apps/auxiliares/documentoLiveCycle/layout")(@constructor)


  customReset: =>
    @singlemovimiento.reset() if @singlemovimiento
    @navigate "/apps"

module.exports = DocumentoLiveCycle