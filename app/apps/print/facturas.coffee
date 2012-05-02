require('lib/setup')
Spine = require('spine')
DocumentoPreparado = require("models/sobjects/documentoPreparado")

class Facturas extends Spine.Controller
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
    @html require("views/apps/print/layout")(@constructor)
    DocumentoPreparado.bind "query_success" , @renderDocumentos
    @renderDocumentos()

  renderDocumentos: =>
    docs= DocumentoPreparado.findAllByAttribute "Tipo_de_Documento" , "FA"
    @html.append require("views/apps/procesos/documentosImpresion/item")(docs)

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

module.exports = Facturas