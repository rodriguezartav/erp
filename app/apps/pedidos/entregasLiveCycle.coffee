Spine = require('spine')
Documento = require("models/documento")
Cliente = require("models/cliente")
PedidoPreparado = require("models/socketModels/pedidoPreparado")
Ruta = require("models/transitory/ruta")

class EntregasLiveCycle extends Spine.Controller
  className: "row-fluid"

  @departamento = "Credito y Cobro"
  @label = "Entregas"
  @icon = "icon-truck"

  events:
    "click .dropdownContainer" : "onDropdownClick"
    "click .btn_new_ruta" : "onBtnNewRutaClick"
    "click .txt_nueva_ruta_btn" : "onSaveRuta"
    "dragover .ruta" : "handleDragOver"
    "drop .ruta" : "handleDrop"
    "dragstart .documentoSinEntregar" : "handleDragStart"
    "click .btn_remove" : "onRutaRemove"

  elements: 
    ".src_sinEntregar" : "sinEntregar"
    ".src_rutas" : "src_rutas"
    ".dropdownContainer" : "dropdownContainer"
    ".txt_nueva_ruta_fecha" : "txtFecha"
    ".txt_nueva_ruta_camion" : "txtCamion"
    ".txt_nueva_ruta_chofer" : "txtChofer"
    ".txt_value" : "txt_value"

  constructor: ->
    super
    @html require("views/apps/pedidos/entregasLiveCycle/layout")(EntregasLiveCycle)
    @onRutaChange()
    
    Documento.destroyAll()
    Ruta.bind "create update destroy" , @onRutaChange

    Documento.ajax().query {sinEntregar: true , v2: true} , afterSuccess: (results) =>
      @renderOrdenes(results)

  onRutaChange: =>
    @src_rutas.html require("views/apps/pedidos/entregasLiveCycle/ruta")(Ruta.all())

  renderOrdenes:  =>
    documentos = Documento.all()
    @sinEntregar.html require("views/apps/pedidos/entregasLiveCycle/item")(documentos)

  onDropdownClick: (e) ->
    return false if !e.saved;

  handleDragStart: (e) =>
    target = $(e.target)
    @currentDraggedDocumentoId = target.data "id";

  handleDragOver: (e) ->
    e.preventDefault() if e.preventDefault
    return false;
    
  handleDrop: (e) =>
    target = $(e.target).parent()
    rutaId = target.data "id"
    ruta = Ruta.find rutaId
    e.stopPropagation() if e.stopPropagation  
    doc = Documento.find @currentDraggedDocumentoId
    ruta.Documentos.push rutaId if ruta.Documentos.indexOf(rutaId) == -1
    ruta.save()
    return false;

  onSaveRuta: (e) =>
    for item in @txt_value
      if item
        return false if $(item).val().lenght == 0
    ruta = Ruta.create Documentos: [] , Fecha: @el.find(".txt_nueva_ruta_fecha").val() , Camion: @el.find(".txt_nueva_ruta_camion").val() ,Chofer: @el.find(".txt_nueva_ruta_chofer").val()
    e.saved = true
    
  onBtnNewRutaClick: =>
    pickers = @el.find(".inputFecha").datepicker({autoclose: true})
    @txt_value.val ""
    
  onRutaRemove: (e) =>
    target = $(e.target)
    id = target.data "id"

    ruta = Ruta.find id
    ruta.destroy()
    
  reset: ->
    @release()
    @navigate "/apps"

module.exports = EntregasLiveCycle