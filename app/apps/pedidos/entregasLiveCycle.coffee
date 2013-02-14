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
    Ruta.bind "create update" , @onRutaChange

    Documento.ajax().query {sinEntregar: true} , afterSuccess: (results) =>
      @renderOrdenes(results)

  onRutaChange: =>
    @src_rutas.html require("views/apps/pedidos/entregasLiveCycle/ruta")(Ruta.all())

  renderOrdenes:  =>
    documentos = Documento.all()
    @sinEntregar.html require("views/apps/pedidos/entregasLiveCycle/item")(documentos)
    
    pickers = @el.find('.txtFecha').datepicker({autoclose: true})
    pickers.off("change",@onInputChange)
    pickers.on("change",@onInputChange)
 
  onDropdownClick: (e) ->
    return false if !e.saved;
    
  onSaveRuta: (e) =>
    for item in @txt_value
      if item
        return false if $(item).val().lenght == 0
    ruta = Ruta.create Fecha: @el.find(".txt_nueva_ruta_fecha").val() , Camion: @el.find(".txt_nueva_ruta_camion").val() ,Chofer: @el.find(".txt_nueva_ruta_chofer").val()
    e.saved = true
    
  onBtnNewRutaClick: =>
    pickers = @el.find(".inputFecha").datepicker({autoclose: true})
    @txt_value.val ""
    
  reset: ->
    @release()
    @navigate "/apps"

module.exports = EntregasLiveCycle