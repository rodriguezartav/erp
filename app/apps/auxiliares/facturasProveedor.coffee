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
  @label = "Compras a Proveedores"
  
  className: "row"

  elements:
    ".error" : "error"
    ".validatable" : "inputs_to_validate"
    "select" : "cuentas"
    ".src_proveedor" : "src_proveedor"

  events:
    "click .cancel" : "reset"
    "click .save" : "send"

  constructor: ->
    super
    @error.hide()
    Cuenta.query {tipos: ["'Gasto'","'Activo'"]}
    Proveedor.query()
    Cuenta.bind "query_success" , @onLoadCuenta
    Cuenta.create { Codigo: '2000' , Name: 'Compra de Mercaderia', Id: 'n/d' }
    @render()
    
  onLoadCuenta: =>
    @cuentas.html require("views/apps/auxiliares/facturasProveedor/itemCuentaGasto")(Cuenta.all())
    
  render: =>  
    @html require("views/apps/auxiliares/facturasProveedor/layout")(@documento)
    @proveedores = new Proveedores(el: @src_proveedor)
    

  #####
  # ACTIONS
  #####
  
  customValidation: =>
    @validationErrors.push "Escoja el Proveedor" if Proveedor.current == null
    
  beforeSend: (object) ->
    object.Proveedor = Proveedor.current.id

  send: (e) =>
    @documento = Documento.create {Tipo_de_Documento: "FP"} if !@documento
    @inputs_to_validate.push @cuentas
    @updateFromView(@documento,@inputs_to_validate)
    Spine.trigger "show_lightbox" , "sendDocumento" , @documento , @after_send
 

  after_send: =>
    @reset(false)
 
  customReset: ->
    Proveedor.reset_current()
    @documento.destroy() if @documento 
      

module.exports = FacturasProveedor