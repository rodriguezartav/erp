require('lib/setup')
Spine = require('spine')
Documento = require("models/documento")
CuentaPorPagar = require("models/cuentaPorPagar")

class DocumentosAnular extends Spine.Controller
  @departamento = "Diario"
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
    @list.empty()
    @reload()

  reload: ->
    Documento.ajax().query( { fecha: "TODAY" } , afterSuccess: @renderDocumentos )
    CuentaPorPagar.ajax().query( { fecha: "TODAY" } , afterSuccess: @renderCuentasPorPagar )

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
    @type = typeName
    data =
       class: cls
       restRoute: "Anular"
       restMethod: "POST"
       restData: id: obj.id , tipo: typeName
    Spine.trigger "show_lightbox" , "rest" , data , @anularSuccess   

  anularSuccess: =>
    Spine.socketManager.pushToFeed("Anule un #{@type}")
    @type = null
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