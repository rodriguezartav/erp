require('lib/setup')
Spine = require('spine')
DocumentoPreparado = require("models/sobjects/documentoPreparado")

class DocumentosImpresion extends Spine.Controller
  @departamento = "Ventas"
  @label = "Impresion de Facturas"
  @icon = "icon-print"
  
  className: "row-fluid"

  events:
    "click .cancel" : "reset"
    "click .print"  : "print"
    "click .reload" : "reload"
    
  elements: 
    ".src_documentos" : "list"

  constructor: ->
    super
    @html require("views/apps/procesos/documentosImpresion/layout")(@constructor)
    DocumentoPreparado.bind "query_success" , @renderDocumentos
    @renderDocumentos()
    @reload()

  reload: =>
    Spine.followDocumentosPreparados()

  renderDocumentos: =>
    @list.empty()
    for doc in DocumentoPreparado.findAllByAttribute "Tipo_de_Documento" , "FA"
      @list.append require("views/apps/procesos/documentosImpresion/item")(doc)

  print: (e) =>
    target = $(e.target)
    id = target.attr "data-id"
    doc = DocumentoPreparado.find(id)
    doc.destroy()
    url = Spine.session.instance_url + "/apex/invoice_topdf?Documento__c_id=" + id
    window.open(url)
    @renderDocumentos()

  reset: =>
    @release()
    DocumentoPreparado.unbind "query_success" , @renderDocumentos
    @navigate "/apps"

module.exports = DocumentosImpresion