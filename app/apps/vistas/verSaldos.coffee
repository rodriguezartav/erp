Spine = require('spine')
Saldo = require("models/socketModels/saldo")
Cliente = require("models/cliente")
Clientes = require("controllers/clientes")
Documento = require("models/documento")

class VerSaldos extends Spine.Controller
  
  className: "row-fluid verSaldos"
  
  @departamento = "Vistas"
  @label = "Ver Saldos"
  @icon = "icon-eye-open"


  elements:
    ".src_cliente"       :  "src_cliente"
    ".js_create_pago"    :  "btn_create_pago"
    ".saldos_list"       : "saldos_list"
    ".lbl_total"         : "lbl_total"
    ".validatable"       : "inputs_to_validate"
    
  events:
    "click .cancel" : "reset"
    "click .save" : "send"

  setBindings: ->
    Documento.bind 'query_success' , @onDocumentoLoaded
 
  preset: ->
    Documento.destroyAll()
    Documento.query({ saldo: true , estado: "Impreso" })

  constructor: ->
    super
    @preset()
    @render()
    @setBindings()
   
  render: ->
    @html require("views/apps/vistas/verSaldos/layout")(VerSaldos)

  onDocumentoLoaded: =>
    @saldos_list.html require("views/apps/vistas/verSaldos/item")(Documento.all())
    

  reset: ->
    Documento.destroyAll()
    @navigate "/apps"

module.exports = VerSaldos