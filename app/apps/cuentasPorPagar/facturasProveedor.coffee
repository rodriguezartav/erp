require('lib/setup')
Spine = require('spine')
Proveedores = require("controllers/proveedores")
Proveedor = require("models/proveedor")
CuentaPorPagar = require("models/cuentaPorPagar")

class FacturasProveedor extends Spine.Controller
  @extend Spine.Controller.ViewDelegation

  @departamento = "Tesoreria"  
  @label = "Ingreso de Documentos"
  @icon = "icon-edit"

  className: "row-fluid"

  elements:
    ".validatable" : "inputs_to_validate"
    "select" : "cuentas"
    ".src_proveedor" : "src_proveedor"
    ".txtPlazo" : "txtPlazo"
    ".subtotal" : "subtotal"
    ".descuento" : "descuento"
    ".impuesto" : "impuesto"
    ".total" : "total"
    ".lbl_total_format" : "lbl_total_format"
    ".btn_tipoGastos_label" : "btn_tipoGastos_label"

  events:
    "click .cancel" : "onCancelar"
    "click .save" : "send"
    "change .totales" : "onTotalesChange"
    "click .btn_tipoGastos" : "onBtnTipoGastos"

  constructor: ->
    super
    @cuentaPorPagar = CuentaPorPagar.create { FechaFacturacion: new Date()  }
    @render()
    @proveedores = new Proveedores(el: @src_proveedor)
    Proveedor.bind "current_set" , @onProveedorSet
    @renderToggle()

  onProveedorSet: =>
    @txtPlazo.val(Proveedor.current.Plazo || 0)
    @setTipoGasto(Proveedor.current.CategoriaGasto || 'N/A')

  renderToggle: =>
    @el.find('.factura_toggle').toggleButtons
      width: 250,
      label:
        enabled: "Factura"
        disabled: "Nota"
      onChange: ($el, status, e) =>
        selectedTipo = if status then "FA" else "NC"
        @cuentaPorPagar.Tipo_de_Documento = selectedTipo
        @cuentaPorPagar.save()
        return true

  render: =>  
    @html require("views/apps/cuentasPorPagar/facturasProveedor/layout")(@constructor)
    @refreshView(@cuentaPorPagar,@inputs_to_validate)    
    
    pickerEl = @el.find('.txtFecha') 
    pickers = pickerEl.datepicker({autoclose: true})
    
    #pickerEl.datepicker('setValue', @cuentaPorPagar.FechaFacturacion)
    pickers.on("change",@onInputChange)
   
  onBtnTipoGastos: (e) =>
    target = $(e.target)
    tipo = target.data "tipo"
    @setTipoGasto tipo

  setTipoGasto: (tipo) =>
    return false if !tipo
    @btn_tipoGastos_label.html tipo
    @cuentaPorPagar.CategoriaGasto__c = tipo
    @cuentaPorPagar.save()

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
    object.FechaIngreso = new Date(Date.now()).to_salesforce_date()
    if object.Tipo_de_Documento == "NC"
      object.Plazo= 1
      object.FechaFacturacion = object.FechaFacturacion.to_salesforce_date()

  send: (e) =>
    @updateFromView(@cuentaPorPagar,@inputs_to_validate)
    Spine.trigger "show_lightbox" , "insert" , @cuentaPorPagar , @after_send

  after_send: =>
    proveedor = @src_proveedor.find("input").val()
    Spine.throttle ->
      Spine.socketManager.pushToProfile("Presidencia" , "He ingresado Cuentas por Pagar")
    , 100000
    @reset(false)
    @onSuccess?()
 
  onCancelar: (e) =>
    @reset()
    @onCancel?()   

  customReset: =>
    Proveedor.reset_current()
    Proveedor.unbind "current_set" , @onProveedorSet
    @cuentaPorPagar.destroy() if @cuentaPorPagar

module.exports = FacturasProveedor