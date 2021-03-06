require('lib/setup')
Spine = require('spine')
FacturaPreparada = require("models/socketModels/facturaPreparada")

class Facturas extends Spine.Controller
  @departamento = "Pedidos"
  @label = "Impresion"
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
    FacturaPreparada.bind "push_success" , @renderDocumentos
    @renderDocumentos()

  reload: ->
    FacturaPreparada.destroyAll()
    FacturaPreparada.ajax().query( {} , afterSuccess: @renderDocumentos )

  renderDocumentos: =>    
    docs= FacturaPreparada.findAllByAttribute "Estado" , "Preparado"
    @list.html require("views/apps/print/item_factura")(docs)

  print: (e) =>
    target = $(e.target)
    id = target.attr "data-id"
    doc = FacturaPreparada.find(id)
    doc.destroy()
    url = Spine.session.instance_url + "/apex/invoice_topdf?Documento__c_id=" + id
    window.open(url)
    @renderDocumentos()

  reset: =>
    @release()
    FacturaPreparada.unbind "query_success" , @renderDocumentos
    FacturaPreparada.unbind "push_success" , @renderDocumentos
    
    @navigate "/apps"

module.exports = Facturas