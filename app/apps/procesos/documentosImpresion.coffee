require('lib/setup')
Spine = require('spine')
Documento = require("models/documento")

class DocumentosImpresion extends Spine.Controller
  @departamento = "Facturacion"
  @label = "Impresion de Documentos"
  
  className: "row"

  events:
    "click .print" : "print"
    "click .cancel" : "reset"
    
    
  elements: 
    ".src_documentos" : "list"

  constructor: ->
    super
    @html require("views/apps/procesos/documentosImpresion/layout")
    Documento.query {estado: "Preparado"}
    Documento.bind "query_success" , @renderDocumentos
  
  renderDocumentos: =>
    @list.html require("views/apps/procesos/documentosImpresion/item")(Documento.all())

  print: (e) =>
    target = $(e.target)
    id = target.attr "data-id"
    doc = Documento.find(id)
    @currentHtml = @el.html()
    @render(doc)
    
  render: (doc) =>
    @html require("views/apps/procesos/documentosImpresion/docs/" + doc.Tipo_de_Documento)(doc)

  reset: =>
    @release()
    Documento.unbind "query_success" , @renderDocumentos
    @navigate "/apps"
    


module.exports = DocumentosImpresion