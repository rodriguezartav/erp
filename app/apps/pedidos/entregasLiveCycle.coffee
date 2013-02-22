Spine = require('spine')
Documento = require("models/documento")
Movimiento = require("models/movimiento")
Cliente = require("models/cliente")
PedidoPreparado = require("models/socketModels/pedidoPreparado")
Ruta  =  require("models/transitory/ruta")
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
    "change .txtEntregadoDetail" : "onTxtEntregadoValorChange"
    "keypress .txtEntregadoDetail" : "onTxtEntregadoEnter"
    "click .btn_entregado" : "onTempDocumentoEntregado"
    "click .btn_add_to_ruta" : "onBtnAddToRuta"
    "click .btn_filter_entregados" : "onBtnFilter"

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
    
  renderDocumentos:  =>
    return false if Movimiento.count() == 0 and Documento.count() ==0
    documentos = Documento.select (item) =>
      return false if @filters.indexOf(item.generalTransporte()) == -1
      return true if !item.EntregadoRuta or item.EntregadoRuta.length == 0
      return false

    documento = documentos.sort (a,b) ->
      f1 = Date.parse(a.FechaEntregaPropuesta)
      f2 = Date.parse(b.FechaEntregaPropuesta)
      return f1 - f2

    @sinEntregar.html require("views/apps/pedidos/entregasLiveCycle/item")(documentos)
    @rutas.render()

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

  onDropdownClick: (e) ->
    return false if !e.saved;

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


  reset: ->
    @ruta = null;
    @release()
    @navigate "/apps"

module.exports = EntregasLiveCycle