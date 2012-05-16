require('lib/setup')
Spine = require('spine')
Documento = require("models/documento")
CuentaPorPagar = require("models/cuentaPorPagar")

class DocumentosAnular extends Spine.Controller
  @departamento = "Credito y Cobro"
  @label = "Anular Documentos"
  @icon = "icon-ban-circle"

  className: "row-fluid"

  events:
    "click .cancel" : "reset"
    "click .anularCuenta"  : "anularCuenta"
    "click .anularDocumento"  : "anularDocumento"
    "click .reload" : "reload"

  elements: 
    ".src_documentos" : "list"

  constructor: ->
    super
    @html require("views/apps/procesos/documentosAnular/layout")(@constructor)
    CuentaPorPagar.destroyAll()
    Documento.destroyAll()
    Documento.bind "query_success" , @renderDocumentos
    CuentaPorPagar.bind "query_success" , @renderCuentasPorPagar
    @list.empty()
    @reload()

  reload: ->
    Documento.query( { fecha: "TODAY" } )
    CuentaPorPagar.query( { fecha: "TODAY" } )

  renderDocumentos: =>
    for doc in Documento.all()
      @list.append require("views/apps/procesos/documentosAnular/item")(doc)

  renderCuentasPorPagar: =>
     for doc in CuentaPorPagar.all()
       @list.append require("views/apps/procesos/documentosAnular/itemCuenta")(doc)


  anularDocumento: (e) =>
    target = $(e.target)
    id = target.attr "data-id"
    @doc = Documento.find(id)
    @anular(Documento , @doc , "Documento")

  anularCuenta: (e) =>
    target = $(e.target)
    id = target.attr "data-id"
    @doc = CuentaPorPagar.find(id)
    @anular(CuentaPorPagar , @doc , "CuentaPorPagar")

  anular: (cls,obj,typeName) ->
    data =
       class: cls
       restRoute: "Anular"
       restMethod: "POST"
       restData: JSON.stringify( { id: obj.id , tipo: typeName } )
    Spine.trigger "show_lightbox" , "rest" , data , @anularSuccess   

  anularSuccess: =>
    @doc.destroy()
    @list.empty()
    @renderDocumentos()
    @renderCuentasPorPagar()

  reset: =>
    @release()
    Documento.unbind "query_success" , @renderDocumentos
    CuentaPorPagar.unbind "query_success" , @renderDocumentos
    @navigate "/apps"

module.exports = DocumentosAnular