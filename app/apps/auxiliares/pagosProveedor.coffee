require('lib/setup')
Spine = require('spine')
Documento = require("models/documento")
Cuenta = require("models/cuenta")
Proveedores = require("controllers/proveedores")
Proveedor = require("models/proveedor")
PagoProveedor = require("models/transitory/pagoProveedor")

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
    ".txt_saldo" : "saldos"
    ".lblTotal" : "lblTotal"

  events:
    "click .cancel" : "reset"
    "click .save" : "send"
    "click .incluir" : "onIncluir"
    "click .excluir" : "onExcluir"

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
    @refreshElements()

  onIncluir: (e) =>
    target = $(e.target)
    id = target.attr "data-id"
    doc = Documento.find id
    tr = target.parents("tr")
    input = tr.find(".txt_saldo")
    input.html doc.Saldo.toMoney()
    input.attr "data-saldo" ,doc.Saldo
    @updateTotal()

  onExcluir: (e) =>
    target = $(e.target)
    id = target.attr "data-id"
    doc = Documento.find id
    tr = target.parents("tr")
    input = tr.find(".txt_saldo")
    input.attr "data-saldo" , 0
    input.html 0
    @updateTotal()

  updateTotal: =>
    total = 0
    for saldo in @saldos
      saldo =  $(saldo)
      total+= parseFloat(saldo.attr("data-saldo"))
    @lblTotal.html total.toMoney()

  #####
  # ACTIONS
  #####
  
  customValidation: =>
    @validationErrors.push "Ingrese al menos un pago" if @saldos.length == 0
    
  beforeSend: (object) ->
    object.Items = []
    for saldo in @saldos
      saldo =  $(saldo)
      monto = parseFloat(saldo.attr("data-saldo"))
      documento = saldo.attr("data-saldo")
      if monto > 0
        object.Items.push {Monto: monto , Documento: documento }
  
  send: (e) =>
    @inputs_to_validate.push @cuentas   
    @pagoProveedor = PagoProveedor.create({})
    @updateFromView(@pagoProveedor,@inputs_to_validate)
    
    Spine.trigger "show_lightbox" , "sendPagoProveedor" , @pagoProveedor , @after_send
 
  after_send: =>
    @pagoProveedor.destroy()
    @reset()

  customReset: ->
    @src_saldos.empty()
    Documento.destroyAll()
    
  

module.exports = PagosProveedor