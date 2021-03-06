require('lib/setup')
Spine = require('spine')
CuentaPorPagar = require("models/cuentaPorPagar")
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
    ".error"         : "error"
    ".validatable"   : "inputs_to_validate"
    ".src_saldos"    : "src_saldos" 
    ".cuentas"       : "cuentas"
    ".src_proveedor" : "src_proveedor"
    ".txt_saldo"     : "saldos"
    ".lblTotal"      : "lblTotal"
    ".txt_tc"        : "txt_tc"

  events:
    "click .cancel" : "reset"
    "click .save" : "send"
    "click .incluir" : "onIncluir"
    "click .excluir" : "onExcluir"

  setBindings: =>
    Proveedor.bind "current_set", @onProveedorSet


  resetBindings: =>
    Proveedor.unbind "current_set", @onProveedorSet

  constructor: ->
    super
    @error.hide()
    CuentaPorPagar.destroyAll()
    Proveedor.reset_current()
    @setBindings()
    @html require("views/apps/cuentasPorPagar/pagosProveedor/layout")(@constructor)
    @proveedores = new Proveedores(el: @src_proveedor)

  onProveedorSet: =>
    CuentaPorPagar.ajax().query( { proveedor: Proveedor.current.id , paraPagar: true } , afterSuccess: @onLoadSaldos )
    
  onLoadSaldos: =>
    @src_saldos.html require("views/apps/cuentasPorPagar/pagosProveedor/saldoItem")(CuentaPorPagar.all())
    @refreshElements()

  onIncluir: (e) =>
    target = $(e.target)
    id = target.attr "data-id"
    doc = CuentaPorPagar.find id
    tc = parseFloat(@txt_tc.val())
    if doc.TipoCambio >1 and tc == 1
      throw "Primero ingrese un tipo de cambio"

    tr = target.parents("tr")
    input = tr.find(".txt_saldo")
    newSaldo = (doc.Saldo / doc.TipoCambio) * tc 
    input.html newSaldo.toMoney()
    input.attr "data-saldo" , newSaldo
    @updateTotal()

  onExcluir: (e) =>
    target = $(e.target)
    id = target.attr "data-id"
    doc = CuentaPorPagar.find id
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
    total

  #####
  # ACTIONS
  #####
  
  customValidation: =>
    @validationErrors.push "Ingrese al menos un pago" if @saldos.length == 0
    
  beforeSend: (object) ->
    object.Items = []
    total = 0
    for saldo in @saldos
      saldo =  $(saldo)
      monto = parseFloat(saldo.attr("data-saldo"))
      documento = saldo.attr("data-id")
      if monto > 0 || monto < 0
        total += monto
        object.Documentos.push documento
        object.Montos.push monto
    throw "El monto del pago debe ser mayor que 0 y es #{total}" if total < 0
  
  send: (e) =>
    @pagoProveedor = PagoProveedor.create({Documentos: [], Montos: [] })
    @updateFromView(@pagoProveedor,@inputs_to_validate)
    @pagoProveedor.id = null
    pagos = pagos: @pagoProveedor
    
    data =
      class: PagoProveedor
      restRoute: "Tesoreria"
      restMethod: "PUT"
      restData: pagos

    Spine.trigger "show_lightbox" , "rest" , data , @after_send   


  after_send: =>
    proveedor = @src_proveedor.find("input").val()
    Spine.socketManager.pushToFeed("He pagado CXP de #{proveedor}")
    @pagoProveedor.destroy()
    @reset()

  customReset: =>
    @src_saldos.empty()
    @resetBindings()
    @proveedores.reset()
    Proveedor.reset_current()
    CuentaPorPagar.destroyAll()
    @navigate "/apps"
    

module.exports = PagosProveedor