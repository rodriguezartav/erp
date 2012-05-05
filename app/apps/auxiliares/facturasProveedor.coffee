require('lib/setup')
Spine = require('spine')
Proveedores = require("controllers/proveedores")
Proveedor = require("models/proveedor")
CuentaPorPagar = require("models/cuentaPorPagar")

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
    @cuentaPorPagar = CuentaPorPagar.create { FechaFacturacion: new Date()  }

  preset: ->
    Proveedor.query()
    
  constructor: ->
    super
    @setVariables()
    @preset()
    @render()

  render: =>  
    @html require("views/apps/auxiliares/facturasProveedor/layout")(@constructor)
    @refreshView(@cuentaPorPagar,@inputs_to_validate)    
    @proveedores = new Proveedores(el: @src_proveedor)

  #####
  # ACTIONS
  #####

  customValidation: =>
    @validationErrors.push "Escoja el Proveedor" if Proveedor.current == null

  beforeSend: (object) ->
    object.Proveedor = Proveedor.current.id
    object.FechaFacturacion = object.FechaFacturacion.to_salesforce_date()

  send: (e) =>
    @updateFromView(@cuentaPorPagar,@inputs_to_validate)
    Spine.trigger "show_lightbox" , "sendCuentaPorPagar" , @cuentaPorPagar , @after_send

  after_send: =>
    @reset(false)
 
  customReset: ->
    Proveedor.reset_current()
    @cuentaPorPagar.destroy() if @cuentaPorPagar
      

module.exports = FacturasProveedor