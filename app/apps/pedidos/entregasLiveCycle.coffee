Spine = require('spine')
Documento = require("models/documento")
Movimiento = require("models/movimiento")
Cliente = require("models/cliente")
PedidoPreparado = require("models/socketModels/pedidoPreparado")
Ruta = require("models/transitory/ruta")

class EntregasLiveCycle extends Spine.Controller
  className: "row-fluid"

  @departamento = "Pedidos"
  @label = "Entregas"
  @icon = "icon-truck"

  events:
    "click .dropdownContainer" : "onDropdownClick"
    "click .btn_new_ruta" : "onBtnNewRutaClick"
    "click .txt_nueva_ruta_btn" : "onSaveRuta"
    "dragover .ruta" : "handleDragOver"
    "drop .ruta" : "handleDrop"
    "dragstart .documentoSinEntregar" : "handleDragStart"
    "click .btn_remove_ruta" : "onRutaRemove"
    "click .btn_remove_documento" : "onDocumentoRemove"
    "change .txtEntregadoDetail" : "onTxtEntregadoValorChange"
    "keypress .txtEntregadoDetail" : "onTxtEntregadoEnter"
    "click .btn_print_ruta" : "onPrintRuta"
    "click .btn_completar_ruta"  : "onCompletarRuta"
    "click .btn_entregado" : "onTempDocumentoEntregado"
    "click .btn_add_to_ruta" : "onBtnAddToRuta"

  elements: 
    ".print" : "print"
    ".src_sinEntregar" : "sinEntregar"
    ".src_rutas" : "src_rutas"
    ".dropdownContainer" : "dropdownContainer"
    ".txt_nueva_ruta_fecha" : "txtFecha"
    ".txt_nueva_ruta_camion" : "txtCamion"
    ".txt_nueva_ruta_chofer" : "txtChofer"
    ".txt_value" : "txt_value"
    ".lblAlert" : "lblAlert"
    ".filterPlaceHolder" : "filterPlaceHolder"

  constructor: ->
    super
    @html require("views/apps/pedidos/entregasLiveCycle/layout")(EntregasLiveCycle)
    
    Documento.destroyAll()
    Ruta.bind "create update destroy" , @onRutaChange
    Documento.bind "update" , @renderDocumentos

    Movimiento.ajax().query {sinEntregar: true , v2: true} , afterSuccess: (results) =>
      @renderDocumentos(results)

    Documento.ajax().query {sinEntregar: true , v2: true} , afterSuccess: (results) =>
      @renderDocumentos(results)

  renderDocumentos:  =>
    return false if Movimiento.count() == 0 and Documento.count() ==0
    filters = Ruta: [] , FechaEntregaPropuesta: [] , Transporte: []
    documentos = Documento.select (item) ->
      item.Rel = Cliente: Cliente.find item.Cliente
      if !item.EntregadoRuta or item.EntregadoRuta.length == 0
        ruta = item.Rel.Cliente.Ruta
        fechaEntrega = item.FechaEntregaPropuesta.toMMMDate()
        transporte = item.generalTransporte()
        filters.Ruta.push ruta if filters.Ruta.indexOf(ruta) == -1
        filters.FechaEntregaPropuesta.push fechaEntrega if filters.FechaEntregaPropuesta.indexOf(fechaEntrega) == -1
        filters.Transporte.push transporte if filters.Transporte.indexOf(transporte) == -1
        return true
      return false
      
      
    documento = documentos.sort (a,b) ->
      f1 = Date.parse(a.FechaEntregaPropuesta)
      f2 = Date.parse(b.FechaEntregaPropuesta)
      return f1 - f2
      
    @filterPlaceHolder.html require("views/apps/pedidos/entregasLiveCycle/filter")(filters)
    @sinEntregar.html require("views/apps/pedidos/entregasLiveCycle/item")(documentos)
    @onRutaChange()
    #@renderPedidosAlert()

  onRutaChange: =>
    rutas = Ruta.all()
    rutas = @createRutasFromDocumentos() if rutas.length == 0
    rutas = rutas.sort (a,b) ->
      f1 = new Date(a.Fecha)
      f2 = new Date(b.Fecha)
      return f1 - f2
    @src_rutas.html require("views/apps/pedidos/entregasLiveCycle/ruta")(rutas)

  
  createRutasFromDocumentos: =>
    documentos = Documento.select (item) ->
      return true if item.EntregadoRuta and item.EntregadoRuta.length > 0
      return false

    tempRutas = {}
    for documento in documentos
      ruta = tempRutas[documento.EntregadoRuta] or Ruta.tempFromString documento.EntregadoRuta
      ruta.Documentos.push documento.id
      tempRutas[documento.EntregadoRuta]  = ruta

    rutas = []
    rutas.push ruta for index,ruta of tempRutas
    return rutas

  renderPedidosAlert: =>
    @lblAlert.empty()
    pedidos = PedidoPreparado.select (item) ->
      return false if item.Estado == "Facturado" or item.Estado == "Archivado"
      return true
      
    clientes = {}
    for pedido in pedidos
      if clientes[pedido.Cliente]
        clientes[pedido.Cliente] += 1 
      else
        clientes[pedido.Cliente] =1;
    @lblAlert.html "Hay Pedidos Preparados de " if pedidos.length > 0    
    for index,value of clientes
      @lblAlert.append "<span>#{Cliente.find(index).Name} : #{value}</span>"

  onDropdownClick: (e) ->
    return false if !e.saved;

  handleDragStart: (e) =>
    target = $(e.target)
    @currentDraggedDocumentoId = target.data "id";

  handleDragOver: (e) ->
    e.preventDefault() if e.preventDefault
    return false;
    
  handleDrop: (e) =>
    target = $(e.target)
    target = target.parent() until target.hasClass "ruta"
    rutaId = target.data "id"
    ruta = Ruta.find rutaId
    e.stopPropagation() if e.stopPropagation 
    doc = Documento.exists @currentDraggedDocumentoId
    if doc
      doc.EntregadoRuta = ruta.toString()
      doc.save()
      @onUpdateDocumento(doc)
      ruta.Documentos.push doc.id if ruta.Documentos.indexOf(doc.id) == -1
      ruta.save()
    else
      console.log @currentDraggedDocumentoId
    return false;

  onBtnAddToRuta: (e) =>
    target = $(e.target)
    rutaId = target.data "ruta"
    ruta = Ruta.find rutaId
    ruta.Documentos.push target.data("id")
    ruta.save()

  onSaveRuta: (e) =>
    for item in @txt_value
      if item
        return false if $(item).val().lenght == 0
    ruta = Ruta.create Documentos: [] , Fecha: @el.find(".txt_nueva_ruta_fecha").val() , Camion: @el.find(".txt_nueva_ruta_camion").val() ,Chofer: @el.find(".txt_nueva_ruta_chofer").val()
    e.saved = true
    
  onBtnNewRutaClick: =>
    pickers = @el.find(".inputFecha").datepicker({autoclose: true})
    @txt_value.val ""

  onTxtEntregadoEnter: (e) ->
    return false if e.keyCode == 13


  onTxtEntregadoValorChange: (e) =>
    e.preventDefault()
    target = $(e.target)
    type = target.data "type"
    id = target.data "id"
    doc = Documento.find id
    doc[type] = target.val()
    doc.save()
    @onUpdateDocumento(doc)

    @onRutaChange()
    return false

  onRutaRemove: (e) =>
    target = $(e.target)
    id = target.data "id"
    ruta = Ruta.find id
    return Spine.trigger "show_lightbox", "showError" , error: "La ruta tiene documentos, borrelos primero." if ruta.Documentos.length > 0
    ruta.destroy()

  onDocumentoRemove: (e) =>
    target = $(e.target)
    id = target.data "id"
    doc = Documento.find id
    doc.EntregadoRuta = ""
    doc.EntregadoValor = ""
    doc.EntregadoGuia = ""
    doc.EntregadoEmpaque = ""
    doc.save()
    @onUpdateDocumento(doc)

    ruta = target.data "ruta"
    ruta = Ruta.find ruta
    index = ruta.Documentos.indexOf id
    if index > -1
      ruta.Documentos.splice index , 1
      ruta.save()

  onPrintRuta: (e) =>
    target = $(e.target)
    id = target.data "id"
    ruta = Ruta.find id
    @print.html require("views/apps/pedidos/entregasLiveCycle/printRuta")(ruta)
    
    for docId in ruta.Documentos
      doc = Documento.find docId
      mov = Movimiento.findAllByAttribute("Documento" , docId)
      @print.append require("views/apps/pedidos/entregasLiveCycle/printRosada")(documento: doc, movimientos: mov)

    window.print()

  onTempDocumentoEntregado: (e) =>
    target = $(e.target)
    id = target.data "id"
    doc = Documento.find id
    doc.EntregadoRuta = ""
    doc.EntregadoValor = 0
    doc.EntregadoGuia = ""
    doc.EntregadoEmpaque = ""
    doc.FechaEntrega = new Date()
    doc.Entregado = true
    @onUpdateDocumento(doc)
    doc.destroy()
    @renderDocumentos()

  onUpdateDocumento: (documento) =>
     documentos = Documento.salesforceFormat( [documento]  , true) 
     
     data =
        class: Documento
        restRoute: "Documento"
        restMethod: "POST"
        restData: documentos: documentos

     Documento.rest( data , afterError: @onUpdateDocumentoError ) 
  
  onUpdateDocumentoError: (error_obj) =>
    Spine.trigger "show_lightbox" , "showError" , error_obj 


  onCompletarRuta: (e) =>
    target = $(e.target)
    id = target.data "id"
    ruta = Ruta.find id
    @ruta = ruta
    documentos = []
    for doc in ruta.Documentos
      documento = Documento.find doc
      documento.FechaEntrega = new Date()
      documento.Entregado = true
      documentos.push documento
    documentos = Documento.salesforceFormat( documentos  , true) 

    data =
      class: Documento
      restRoute: "Documento"
      restMethod: "POST"
      restData: documentos: documentos

    Spine.trigger "show_lightbox" , "rest" , data , @onCompletarRutaSuccess

  onCompletarRutaSuccess: =>
    @ruta.destroy();
    @reset()

  reset: ->
    @ruta = null;
    @release()
    @navigate "/apps"

module.exports = EntregasLiveCycle