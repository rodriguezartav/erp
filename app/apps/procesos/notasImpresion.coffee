require('lib/setup')
Spine = require('spine')
DocumentoPreparado = require("models/sobjects/documentoPreparado")

class NotasImpresion extends Spine.Controller
  @departamento = "Facturacion"
  @label = "Impresion de Notas"
  
  className: "row"

  events:
    "click .cancel" : "reset"
    "click .print"  : "print"
    "click .reload" : "reload"
    
  elements: 
    ".src_documentos" : "list"

  constructor: ->
    super
    @html require("views/apps/procesos/documentosImpresion/layout")
    DocumentoPreparado.bind "query_success" , @renderDocumentos
    @renderDocumentos()
    @reload()

  renderDocumentos: =>
    @list.empty()
    for doc in DocumentoPreparado.filterNotas()
      @list.append require("views/apps/procesos/documentosImpresion/item")(doc)

  reload: =>
    DocumentoPreparado.query({})

  print: (e) =>
    @body = $("body")
    target = $(e.target)
    id = target.attr "data-id"
    doc = DocumentoPreparado.find(id)
    html = require("views/apps/procesos/documentosImpresion/docs/NC")(doc)
    url = "/print/#{doc.id}"    
    doc.destroy()
    window.open(url)
    @renderDocumentos()

  reset: =>
    @release()
    DocumentoPreparado.unbind "query_success" , @renderDocumentos
    @navigate "/apps"

module.exports = NotasImpresion