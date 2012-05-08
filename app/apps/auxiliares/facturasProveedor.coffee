require('lib/setup')
Spine = require('spine')
Proveedores = require("controllers/proveedores")
Proveedor = require("models/proveedor")
Cuenta = require("models/cuenta")

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

  events:
    "click .cancel" : "reset"
    "click .save" : "send"
    "change .totales" : "onTotalesChange"

  setVariables: ->
    @cuentaPorPagar = CuentaPorPagar.create { FechaFacturacion: new Date()  }

  preset: ->
    Proveedor.query()
    #Cuenta.query({tipos: ["'Bancaria'"] } )
    
  constructor: ->
    super
    @setVariables()
    @preset()
    #Cuenta.bind "query_success" , @onLoadCuenta
    Proveedor.bind "current_set" , @onProveedorSet
    
    @render()
    
    
  onProveedorSet: =>
    @txtPlazo.val(Proveedor.current.Plazo || 0)

  onLoadCuenta: =>
    @cuentas.html require("views/apps/auxiliares/pagosProveedor/itemCuentaGasto")(Cuenta.all())


  render: =>  
    @html require("views/apps/auxiliares/facturasProveedor/layout")(@constructor)
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
    object.FechaFacturacion = object.FechaFacturacion.to_salesforce_date()

  send: (e) =>
    #@inputs_to_validate.push @cuentas
    @updateFromView(@cuentaPorPagar,@inputs_to_validate)
 
    data =
      class: CuentaPorPagar
      restData: [@cuentaPorPagar]

    Spine.trigger "show_lightbox" , "insert" , data , @after_send
    
 
 
   
  after_send: =>
    @reset(false)
 
  customReset: ->
    Proveedor.reset_current()
    @cuentaPorPagar.destroy() if @cuentaPorPagar
      

module.exports = FacturasProveedor