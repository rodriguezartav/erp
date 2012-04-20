require('lib/setup')
Spine = require('spine')
Documento = require("models/documento")
Cuenta = require("models/cuenta")
Proveedores = require("controllers/proveedores")
Proveedor = require("models/proveedor")


class PagosProveedor extends Spine.Controller
  @extend Spine.Controller.ViewDelegation

  className: "row-fluid"

  @departamento = "Tesoreria"
  @label = "Pagos a Proveedores"
  @icon = "icon-inbox"
  

  elements:
    ".error" : "error"
    ".validatable" : "inputs_to_validate"
    ".src_saldos" : "src_saldos" 
    ".cuentas" : "cuentas"
    ".src_proveedor" : "src_proveedor"

  events:
    "click .cancel" : "reset"
    "click .save" : "send"

  constructor: ->
    super
    @error.hide()
    Documento.destroyAll()
    
    Cuenta.query({tipos: ["'Bancaria'"] } )
    Proveedor.query()
    
    Cuenta.bind "query_success" , @onLoadCuenta
    Documento.bind "query_success" , @onLoadSaldos
    
    Proveedor.bind "current_set", @onProveedorSet
    
    @html require("views/apps/auxiliares/pagosProveedor/layout")(@constructor)
    @proveedores = new Proveedores(el: @src_proveedor)
    
    
  onProveedorSet: =>
    Documento.query({ proveedor: Proveedor.current.id , tipos: ["'FP'"] , saldo: true , aprobadoParaPagar: true})
    
  onLoadCuenta: =>
    @cuentas.html require("views/apps/auxiliares/pagosProveedor/itemCuentaGasto")(Cuenta.all())
    
  onLoadSaldos: =>
    @src_saldos.html require("views/apps/auxiliares/pagosProveedor/saldoItem")(Documento.all())


  #####
  # ACTIONS
  #####
  
  customValidation: =>
    @validationErrors.push "Ingrese el Nombre del Cliente" if Cliente.current == null
    
#  beforeSend: (object) ->

    
  send: (e) =>
 #   @inputs_to_validate.push @cuentas   
#    @updateFromView(@documento,@inputs_to_validate)
    
    alert "Todavia no esta desarrollado el metodo de pago"
    #Spine.trigger "show_lightbox" , "sendPago" , @pago , @after_send
 
  after_send: =>
    @reset()

  customReset: ->
    @src_saldos.empty()
    Documento.destroyAll()
    @pago.destroy() if @pago   
    
  

module.exports = PagosProveedor