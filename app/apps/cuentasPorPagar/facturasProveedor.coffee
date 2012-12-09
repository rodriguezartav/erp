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
    ".txtPlazo" : "txtPlazo"
    ".subtotal" : "subtotal"
    ".descuento" : "descuento"
    ".impuesto" : "impuesto"
    ".total" : "total"
    ".lbl_total_format" : "lbl_total_format"

  events:
    "click .cancel" : "reset"
    "click .save" : "send"
    "change .totales" : "onTotalesChange"

  constructor: ->
    super
    @cuentaPorPagar = CuentaPorPagar.create { FechaFacturacion: new Date()  }
    @render()
    @proveedores = new Proveedores(el: @src_proveedor)
    Proveedor.bind "current_set" , @onProveedorSet

  onProveedorSet: =>
    @txtPlazo.val(Proveedor.current.Plazo || 0)

  render: =>  
    @html require("views/apps/cuentasPorPagar/facturasProveedor/layout")(@constructor)
    @refreshView(@cuentaPorPagar,@inputs_to_validate)    
    
    pickerEl = @el.find('.txtFecha') 
    pickers = pickerEl.datepicker({autoclose: true})
    
    #pickerEl.datepicker('setValue', @cuentaPorPagar.FechaFacturacion)
    pickers.on("change",@onInputChange)
    
  #####
  # ACTIONS
  #####

  onInputChange: (e) =>
    target = $(e.target)
    @cuentaPorPagar.FechaFacturacion = new Date(Date.parse(target.val()));
    @cuentaPorPagar.save()
    return false;

  onTotalesChange: =>
    sub = parseFloat(@subtotal.val()) || 0
    desc = parseFloat(@descuento.val()) || 0
    imp = parseFloat(@impuesto.val()) || 0
    @total.val sub - desc + imp
    @lbl_total_format.html (sub - desc + imp).toMoney()

  customValidation: =>
    @validationErrors.push "Escoja el Proveedor" if Proveedor.current == null

  beforeSend: (object) =>
    object.Proveedor = Proveedor.current.id
    object.Tipo_de_Documento = 'FA'
    object.FechaIngreso = new Date(Date.now()).to_salesforce_date()

  send: (e) =>
    @updateFromView(@cuentaPorPagar,@inputs_to_validate)
    Spine.trigger "show_lightbox" , "insert" , @cuentaPorPagar , @after_send

  after_send: =>
    proveedor = @src_proveedor.find("input").val()
    Spine.throttle ->
      Spine.socketManager.pushToProfile("Presidencia" , "He ingresado Cuentas por Pagar")
    , 100000
    @reset(false)
 
  customReset: ->
    Proveedor.reset_current()
    Proveedor.unbind "current_set" , @onProveedorSet
    @cuentaPorPagar.destroy() if @cuentaPorPagar
    @navigate "/apps"
    

module.exports = FacturasProveedor