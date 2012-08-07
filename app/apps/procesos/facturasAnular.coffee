require('lib/setup')
Spine = require('spine')
Documento = require("models/documento")

class FacturasAnular extends Spine.Controller
  @departamento = "Credito y Cobro"
  @label = "Anular Facturas"
  @icon = "icon-ban-circle"

  className: "row-fluid"

  events:
    "click .cancel" : "reset"
    "click .anular"  : "anular"
    "click .reload" : "reload"

  elements: 
    ".src_documentos" : "list"

  constructor: ->
    super
    @html require("views/apps/procesos/facturasAnular/layout")(@constructor)
    Documento.destroyAll()
    Documento.bind "query_success" , @renderDocumentos
    @reload()

  reload: ->
    Documento.query( { tipos: "'FA'" ,  fecha: "TODAY" } )

  renderDocumentos: =>
    @list.empty()
    for doc in Documento.all()
      @list.append require("views/apps/procesos/facturasAnular/item")(doc)

  anular: (e) =>
    target = $(e.target)
    id = target.attr "data-id"
    @doc = Documento.find(id)

    data =
      class: Documento
      restRoute: "Anular"
      restMethod: "POST"
      restData: JSON.stringify( { id: @doc.id , tipo: "Documento" } )

    Spine.trigger "show_lightbox" , "rest" , data , @anularSuccess   

  anularSuccess: =>
    @doc.destroy()
    @renderDocumentos()

  reset: =>
    @release()
    Documento.unbind "query_success" , @renderDocumentos
    @navigate "/apps"

module.exports = FacturasAnular