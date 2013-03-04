Spine = require('spine')
Documento = require("models/socketModels/facturaEntregada")
Movimiento = require("models/movimiento")
Cliente = require("models/cliente")
PedidoPreparado = require("models/socketModels/pedidoPreparado")
Ruta  =  require("models/ruta")
Rutas =  require("apps/pedidos/entregasLiveCycle_RutasView")

class EntregasLiveCycle extends Spine.Controller
  className: "row-fluid"

  @departamento = "Pedidos"
  @label = "Entregas"
  @icon = "icon-truck"

  events:
    "click .dropdownContainer" : "onDropdownClick"
    "click .btn_new_ruta" : "onBtnNewRutaClick"
    "click .txt_nueva_ruta_btn" : "onSaveRuta"
    "click .btn_entregado" : "onDocumentoEntregado"
    "click .btn_add_to_ruta" : "onBtnAddToRuta"
    "click .btn_filter_entregados" : "onBtnFilter"
    "click .btn_imprimir" : "onBtnImprimir"
    "click .btn_imprimir_rosada" : "onBtnImprimirRosada"

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
    ".documentoSinEntregar" : "documentoSinEntregar"
    ".btn_filter_entregados" : "btn_filter_entregados"
    

  constructor: ->
    super
    @html require("views/apps/pedidos/entregasLiveCycle/layout")(EntregasLiveCycle)
    @rutas = new Rutas(el: @src_rutas , print: @print , entregasLiveCycle: @)
    @filters = ["Cliente","Agente","Transporte","Rodco"]
    Documento.destroyAll()

    Documento.bind "update" , @renderDocumentos

    Documento.bind "push_success" , @renderDocumentos

    Movimiento.ajax().query {sinEntregar: true , v2: true} , afterSuccess: (results) =>
      @renderDocumentos(results)

    Documento.ajax().query {sinEntregar: true , v2: true} , afterSuccess: (results) =>
      @renderDocumentos(results)

  onBtnFilter: (e) =>
    target = $(e.target)
    filters = target.data "filter"
    filters = filters.split ","
    btn = target.parent()
    if btn.hasClass "active"
      btn.removeClass "active"
      @filters.removeItems filters
    else
      @filters.addUniqueItems filters 
      btn.addClass "active"
    @renderDocumentos()
    
  filterByRuta: (rutas) =>
    @el.find("a+.btn_filter_entregados").removeClass "active"
    documentos = Documento.select (item) =>
      cliente = Cliente.find item.Cliente
      return false if rutas.indexOf( cliente.RutaTransporte ) == -1
      return true if item.hasEntregadoRuta() == false
      return false
    @renderHtml documentos

  renderDocumentos:  =>
    return false if Movimiento.count() == 0 and Documento.count() ==0
    pending = []
    for documento in Documento.all()
      if documento.hasEntregadoRuta() == false
        pending.push documento
      else
        if !Ruta.findByName(documento.EntregadoRuta) then Ruta.createFromString documento.EntregadoRuta
    
    @renderHtml pending
    @rutas.render()
    
  groupByFecha: (documentos) =>
    mapFecha = {}
    for documento in documentos
      list = mapFecha[documento.FechaEntregaPropuesta] or []
      list.push documento
      mapFecha[documento.FechaEntregaPropuesta] = list
    return mapFecha

  renderHtml: (documentos) =>
    mapFecha = @groupByFecha(documentos)

    @sinEntregar.html ""
    for index,list of mapFecha
      list = list.sort (a,b) ->
        return Date.parse(a.FechaPedido) - Date.parse(b.FechaPedido)

      @sinEntregar.append "<li class='label'>#{index.toMMMDate()}</li>"
      for documento in list
        @sinEntregar.append require("views/apps/pedidos/entregasLiveCycle/item")(documento)

  onDropdownClick: (e) ->
    return false if !e.saved;

  onDocumentoEntregado: (e) ->
    target = $(e.target)
    docId = target.data("id")

    doc = Documento.find docId
    doc.Entregado = true;
    doc.EntregadoRuta = 'Entregado Sin Ruta';
    doc.save()
    @updateDocumento(doc);
    
    showInfo = false
    for documento in Documento.findAllByAttribute("Cliente" , doc.Cliente)
      showInfo = true if !documento.hasEntregadoRuta()

    if showInfo
      cliente = Cliente.find doc.Cliente
      Spine.trigger 'show_lightbox', "showInfo" , "Hay mas facturas de #{cliente.Name}" 
      Spine.trigger "hide_lightbox" , 2000

  onBtnAddToRuta: (e) =>
    target = $(e.target)
    rutaName = target.data "ruta"
    ruta = Ruta.findByName rutaName
    docId = target.data("id")

    
    doc = Documento.find docId
    doc.EntregadoRuta = ruta.toString()
    doc.save()
    @updateDocumento(doc);
    
    
    showInfo = false
    for documento in Documento.findAllByAttribute("Cliente" , doc.Cliente)
      showInfo = true if documento.hasEntregadoRuta() == false

    if showInfo
      cliente = Cliente.find doc.Cliente
      Spine.trigger 'show_lightbox', "showInfo" , "Hay mas pedidos de #{cliente.Name}" 
      Spine.trigger "hide_lightbox" , 2000

  onBtnImprimir: (e) =>
    target = $(e.target)
    id = target.data "id"
    doc = Documento.find id
    mov = Movimiento.findAllByAttribute("Documento" , doc.id)
    @print.html require("views/apps/pedidos/entregasLiveCycle/printBoleta")(documento: doc, movimientos: mov)
    @print.find("div:last-child").css("page-break-after","avoid")
    window.print()


  onBtnImprimirRosada: (e) =>
    target = $(e.target)
    id = target.data "id"
    doc = Documento.find id
    mov = Movimiento.findAllByAttribute("Documento" , doc.id)
    @print.html require("views/apps/pedidos/entregasLiveCycle/printRosada")(documento: doc, movimientos: mov)
    window.print()


  onSaveRuta: (e) =>
    for item in @txt_value
      if item
        return false if $(item).val().lenght == 0
    ruta = Ruta.createFromAttributes Fecha: @el.find(".txt_nueva_ruta_fecha").val() , Camion: @el.find(".txt_nueva_ruta_camion").val() , Chofer: @el.find(".txt_nueva_ruta_chofer").val()

    e.saved = true
    @renderDocumentos()

  onBtnNewRutaClick: =>
    pickers = @el.find(".inputFecha").datepicker({autoclose: true})
    @txt_value.val ""

  updateDocumento: (documento) =>
     documentos = Documento.salesforceFormat( [documento]  , true) 
     
     data =
        class: Documento
        restRoute: "Documento"
        restMethod: "POST"
        restData: documentos: documentos

     Documento.rest( data , afterError: @onUpdateDocumentoError ) 
  
  updateDocumentoError: (error_obj) =>
    Spine.trigger "show_lightbox" , "showError" , error_obj 

  updateDocumentos: (documentos , callback ) =>
    documentos = Documento.salesforceFormat( documentos  , true) 

    data =
      class: Documento
      restRoute: "Documento"
      restMethod: "POST"
      restData: documentos: documentos

    Spine.trigger "show_lightbox" , "rest" , data , callback


  reset: =>
    Documento.unbind "update" , @renderDocumentos
    Documento.unbind "push_success" , @renderDocumentos
    @release()
    @navigate "/apps"

module.exports = EntregasLiveCycle