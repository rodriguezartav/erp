require('lib/setup')
Spine = require('spine')
Proveedores = require("controllers/proveedores")
Proveedor = require("models/proveedor")
Documento = require("models/documento")
Movimiento = require("models/movimiento")
Cuenta = require("models/cuenta")

class FacturasProveedor extends Spine.Controller
  @extend Spine.Controller.ViewDelegation

  @departamento = "Tesoreria"  
  @label = "Ingreso de Facturas"
  @icon = "icon-edit"

  className: "row-fluid"

  elements:
    ".error" : "error"
    ".validatable" : "inputs_to_validate"
    "select" : "cuentas"
    ".src_proveedor" : "src_proveedor"

  events:
    "click .cancel" : "reset"
    "click .save" : "send"

  setVariables: ->
    @documento = Documento.create { FechaFacturacion: new Date() , Tipo_de_Documento: "FP" }

  preset: ->
    Proveedor.query()
    
  constructor: ->
    super
    @setVariables()
    @preset()
    @render()
    
    
  render: =>  
    @html require("views/apps/auxiliares/facturasProveedor/layout")(@constructor)
    @refreshView(@documento,@inputs_to_validate)    
    @proveedores = new Proveedores(el: @src_proveedor)

  #####
  # ACTIONS
  #####

  customValidation: =>
    @validationErrors.push "Escoja el Proveedor" if Proveedor.current == null

  beforeSend: (object) ->
    object.Proveedor = Proveedor.current.id
    object.Estado = ""

  send: (e) =>
    @updateFromView(@documento,@inputs_to_validate)
    Spine.trigger "show_lightbox" , "sendDocumento" , @documento , @after_send

  after_send: =>
    @reset(false)
 
  customReset: ->
    Proveedor.reset_current()
    @documento.destroy() if @documento 
      

module.exports = FacturasProveedor