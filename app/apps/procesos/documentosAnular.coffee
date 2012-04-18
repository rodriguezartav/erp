require('lib/setup')
Spine = require('spine')
Documento = require("models/documento")

class DocumentosAnular extends Spine.Controller
  @departamento = "Facturacion"
  @label = "Anulacion de Facturas"
  
  className: "row-fluid"

  events:
    "click .cancel" : "reset"
    "click .anular"  : "anular"
    "click .reload" : "reload"
    
  elements: 
    ".src_documentos" : "list"

  constructor: ->
    super
    @html require("views/apps/procesos/documentosAnular/layout")(@constructor)
    Documento.destroyAll()
    Documento.bind "query_success" , @renderDocumentos
    Documento.query({ tipos: ["'FA'"] , fecha: "TODAY" , estado: "Impreso" })

  renderDocumentos: =>
    @list.empty()
    for doc in Documento.all()
      @list.append require("views/apps/procesos/documentosAnular/item")(doc)

  anular: (e) =>
    target = $(e.target)
    id = target.attr "data-id"
    @doc = Documento.find(id)
    Spine.trigger "show_lightbox" , "anularDocumento" , @doc , @anularSuccess
    @renderDocumentos()

  anularSuccess: =>
    @doc.destroy()
    @renderDocumentos()

  reset: =>
    @release()
    Documento.unbind "query_success" , @renderDocumentos
    @navigate "/apps"

module.exports = DocumentosAnular