require('lib/setup')
Spine = require('spine')
Recibo = require("models/recibo")
User = require("models/user")

class RecibosConversion extends Spine.Controller
  className: "row"

  @departamento = "Credito y Cobro"
  @label = "Pagos"

  elements:
    ".error"           : "error"
    ".src_recibos"     : "src_recibos" 

  events:
    "click .cancel"                     : "reset"
    "click .convertir"                   : "onConvertir"
    "click .reload"                      : "loadRecibos"
    "change input.search_vendedores"     : "filterVendedor"
    "change input.search_codigoExterno"  : "filterCodigoExterno"

  constructor: ->
    super
    @error.hide()
    @html require("views/apps/procesos/recibosConversion/layout")(RecibosConversion)
    Recibo.bind "query_success" , @renderRecibos
    @loadRecibos()

  loadRecibos: =>
    Recibo.destroyAll()
    Recibo.query({estado: "Aprobado"})

  renderRecibos: (options = {}) =>
    if options.vendedor 
      recibos = Recibo.filterVendedor(options.vendedor)
    else if options.codigoExterno
      recibos = Recibo.findAllByAttribute("CodigoExterno",options.codigoExterno)
    else  
     recibos = Recibo.all()  
    
    @src_recibos.html require("views/apps/procesos/recibosConversion/item")(recibos)
    $(".popable").popover({})

  filterVendedor: (e) =>
    target = $(e.target)
    if Recibo.count() > 0
      @renderRecibos( {vendedor: target.val() } )
    else
      target.val ""
      return false

  filterCodigoExterno: (e) =>
    target = $(e.target)
    if Recibo.count() > 0
      @renderRecibos( { codigoExterno: target.val() } )
    else
      target.val ""
      return false

  onConvertir: (e) =>
    target = $(e.target)
    id = target.attr "data-id"
    @recibo = Recibo.find id
    Spine.trigger "show_lightbox" , "convertirRecibos" , { recibo: @recibo  } , @convertirSuccess

  convertirSuccess: =>
    @recibo.destroy()
    @loadRecibos()

  reset: ->
    Recibo.unbind "query_success" , @renderRecibos
    @release()
    @customReset?()
    @navigate "/apps"

module.exports = RecibosConversion