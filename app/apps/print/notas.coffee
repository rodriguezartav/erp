require('lib/setup')
Spine = require('spine')
Documento = require("models/documento")

class Notas extends Spine.Controller
  @departamento = "Credito y Cobro"
  @label = "Impresion de Notas"
  @icon = "icon-print"

  className: "row-fluid"

  events:
    "click .cancel" : "reset"
    "click .print"  : "on_print"
    "click .reload" : "reload"
    
  elements: 
    ".src_documentos" : "list"

  constructor: ->
    super
    @html require("views/apps/print/layout")(@constructor)
    Documento.destroyAll()
    Documento.bind "query_success" , @renderDocumentos
    @renderDocumentos()
    @reload()
    

  renderDocumentos: =>
    @list.html require("views/apps/print/item")(Documento.all())

  reload: =>
    Documento.destroyAll()
    Documento.query( { tipos: "'NC','ND'"  } )

  on_print: (e) =>
    target = $(e.target)
    id = target.attr "data-id"
    doc = Documento.find(id)
    @saveUIState()
    @canvas = $("<div></div>")
    @canvas.html require("views/apps/print/NC")(doc)
    $("body").append @canvas
    $(".goBack").one "click",   @goBack
    doc.destroy()
    print()

  goBack: =>
    @restoreUIState()

  saveUIState: =>
    @appCanvas = $(".app")
    @appBack = $(@appCanvas).hide()
    

  restoreUIState: =>
    @appBack.show()
    @canvas.remove()
    @renderDocumentos()

  reset: =>
    Documento.unbind "query_success" , @renderDocumentos
    window.location.reload()

module.exports = Notas