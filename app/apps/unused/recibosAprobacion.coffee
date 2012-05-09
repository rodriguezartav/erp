require('lib/setup')
Spine = require('spine')
Recibo = require("models/recibo")
User = require("models/user")

class RecibosAprobacion extends Spine.Controller
  className: "row"

  @departamento = "Tesoreria"
  @label = "Aprobacion de Recibos"

  elements:
    ".error" : "error"
    ".src_recibos" : "src_recibos" 
    ".content" : "content"


  events:
    "click .cancel"                   : "reset"
    "click .aprobar"                  : "onAprobar"
    "click .archivar"                 : "onArchivar"
    "click .reload"                   : "loadRecibos"
    "click .select_all"               : "selectAll"
    "change input.search_vendedores"  : "filterVendedor"
    "change input.search_referencia"  : "filterReferencia"


  constructor: ->
    super
    @error.hide()
    @html require("views/apps/procesos/recibosAprobacion/layout")(RecibosAprobacion)
    Recibo.bind "query_success" , @renderRecibos
    @loadRecibos()

  loadRecibos: =>
    Recibo.destroyAll()
    Recibo.query({estado: "Nuevo"})

  renderRecibos: (options = {}) =>
    if options.vendedor 
      recibos = Recibo.filterVendedor(options.vendedor)
    else if options.referencia
      recibos = Recibo.filterReferencia(options.referencia)
    else  
     recibos = Recibo.all()  
    
    @src_recibos.html require("views/apps/procesos/recibosAprobacion/item")(recibos)
    $(".popable").popover({})

  selectAll: (e) =>
    target = $(e.target)
    checkboxes = @el.find(".recibo_checkbox")
    if target.is(':checked')
      checkboxes.attr('checked', true);
    else
      checkboxes.attr('checked', false);

  filterVendedor: (e) =>
    target = $(e.target)
    if Recibo.count() > 0
      @renderRecibos( {vendedor: target.val() } )
    else
      target.val ""
      return false

  filterReferencia: (e) =>
    target = $(e.target)
    if Recibo.count() > 0
      @renderRecibos( { referencia: target.val() } )
    else
      target.val ""
      return false

  getCheckboxesIds: =>
    ids = []
    checkboxes = @el.find(".recibo_checkbox")
    for rawCheck in checkboxes
      check =$(rawCheck)
      if check.is(':checked')
        ids.push check.attr "data-id"
    ids

  onAprobar: (e) =>
    ids = @getCheckboxesIds()
    estado =  "Aprobado"
    Spine.trigger "show_lightbox" , "aprobarRecibos" , { ids: ids , estado: estado } , @aprobarSuccess

  onArchivar: (e) =>
    ids = @getCheckboxesIds()
    estado =  "Archivado"
    Spine.trigger "show_lightbox" , "aprobarRecibos" , { ids: ids , estado: estado } , @aprobarSuccess

  aprobarSuccess: =>
    @loadRecibos()

  reset: ->
    Recibo.unbind "query_success" , @renderRecibos
    @release()
    @customReset?()
    @navigate "/apps"

module.exports = RecibosAprobacion