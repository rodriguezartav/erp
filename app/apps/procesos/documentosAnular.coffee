require('lib/setup')
Spine = require('spine')
Documento = require("models/documento")
Movimiento = require("models/movimiento")

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
    "click .btn_search" : "onSearch"
    "click .showItems"  : "onShowItems"
    "click .txt_item_detail" : "onTxtItemDetailClick"
    "click .btn_item_action" : "onBtnItemAction"

  elements: 
    ".src_documentos" : "list"
    ".txt_search" : "txt_search"
    

  constructor: ->
    super
    @html require("views/apps/procesos/documentosAnular/layout")(@constructor)
    @beforeSearch()
    @reload()

  beforeSearch: =>
    CuentaPorPagar.destroyAll()
    Documento.destroyAll()
    @list.empty()

  reload: ->
    Documento.ajax().query( { fecha: "TODAY" } , afterSuccess: @renderDocumentos )
    CuentaPorPagar.ajax().query( { fecha: "TODAY" } , afterSuccess: @renderCuentasPorPagar )

  renderDocumentos: =>
    for doc in Documento.all()
      @list.append require("views/apps/procesos/documentosAnular/item")(doc)

  renderCuentasPorPagar: =>
     for doc in CuentaPorPagar.all()
       @list.append require("views/apps/procesos/documentosAnular/itemCuenta")(doc)

  onSearch: =>
    @beforeSearch()
    Documento.ajax().query( { consecutivo: @txt_search.val() } , afterSuccess: @renderDocumentos )
    
  onShowItems: (e) =>
    target = $(e.target)
    group = target.parents ".showItemsPlaceHolder"
    consecutivo = group.data "consecutivo"
    Movimiento.destroyAll()
    Movimiento.ajax().query { consecutivo: consecutivo } , afterSuccess: =>
      ul = group.find ".itemsMenu"
      ul.html require("views/apps/procesos/documentosAnular/movimientoItemDetail")()
      ul.append require("views/apps/procesos/documentosAnular/movimientoItem")(Movimiento.all())

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

  onBtnItemAction: (e) =>
    target = $(e.target)
    malo = target.data "malo"
    group = target.parents "ul"
    referencia = group.find(".txt_referencia").val()
    observacion = group.find(".txt_observacion").val()
    id = target.data "id"
    cantidadInput = target.siblings("input")
    cantidad = parseFloat(cantidadInput.val())
    return false if cantidad == null or cantidad == undefined or cantidad == NaN
    @devolucionMovimiento(malo,cantidad ,referencia,observacion,id) if referencia and observacion

  devolucionMovimiento: (malo,cantidad,referencia,observacion,id) =>
    data =
       class: Movimiento
       restRoute: "Anular"
       restMethod: "Put"
       restData: id: id , cantidad: cantidad , referencia: referencia , observacion: observacion , estaMalo: malo
    Spine.trigger "show_lightbox" , "rest" , data , @onDevolucionMovimientSuccess   
  
  onDevolucionMovimientSuccess: =>
    @beforeSearch()
    @reload()
  
  onTxtItemDetailClick: (e) =>
    return false

  reset: =>
    @release()
    Documento.unbind "query_success" , @renderDocumentos
    CuentaPorPagar.unbind "query_success" , @renderDocumentos
    @navigate "/apps"

module.exports = DocumentosAnular