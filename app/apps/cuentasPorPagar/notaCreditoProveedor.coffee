require('lib/setup')
Spine = require('spine')
Proveedores = require("controllers/proveedores")
Proveedor = require("models/proveedor")
CuentaPorPagar = require("models/cuentaPorPagar")

class NotaCreditoProveedor extends Spine.Controller
  @extend Spine.Controller.ViewDelegation

  @departamento = "Tesoreria"  
  @label = "Ingreso de Notas"
  @icon = "icon-edit"

  className: "row-fluid"

  elements:
    ".error" : "error"
    ".validatable" : "inputs_to_validate"
    "select" : "cuentas"
    ".src_proveedor" : "src_proveedor"
    ".txtPlazo" : "txtPlazo"
    ".subtotal" : "subtotal"
    ".descuento" : "descuento"
    ".impuesto" : "impuesto"
    ".total" : "total"

  events:
    "click .cancel" : "reset"
    "click .save" : "send"
    "change .totales" : "onTotalesChange"

  setVariables: ->
    @cuentaPorPagar = CuentaPorPagar.create { FechaFacturacion: new Date()  }

  preset: ->

  constructor: ->
    super
    @setVariables()
    @preset()
    @render()


  render: =>  
    @html require("views/apps/cuentasPorPagar/notasProveedor/layout")(@constructor)
    @refreshView(@cuentaPorPagar,@inputs_to_validate)    
    @proveedores = new Proveedores(el: @src_proveedor)

  #####
  # ACTIONS
  #####

  onTotalesChange: =>
    sub = parseFloat(@subtotal.val()) || 0
    desc = parseFloat(@descuento.val()) || 0
    imp = parseFloat(@impuesto.val()) || 0
    @total.val sub - desc + imp

  customValidation: =>
    @validationErrors.push "Escoja el Proveedor" if Proveedor.current == null

  beforeSend: (object) ->
    object.Proveedor = Proveedor.current.id
    object.CuentaGasto = @cuentas.find("option:selected").val()
    
    object.Tipo_de_Documento = 'NC'
    object.Plazo= 1
    object.FechaFacturacion = object.FechaFacturacion.to_salesforce_date()
    object.FechaIngreso = new Date(Date.now()).to_salesforce_date()

  send: (e) =>
    #@inputs_to_validate.push @cuentas
    @updateFromView(@cuentaPorPagar,@inputs_to_validate)

    Spine.trigger "show_lightbox" , "insert" , @cuentaPorPagar , @after_send

  after_send: =>
    @reset(false)
 
  customReset: ->
    Proveedor.reset_current()
    @cuentaPorPagar.destroy() if @cuentaPorPagar
    @navigate "/apps"
    

module.exports = NotaCreditoProveedor