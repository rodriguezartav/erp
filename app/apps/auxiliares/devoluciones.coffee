require('lib/setup')
Spine = require('spine')
Documento = require("models/documento")
Cliente = require("models/cliente")
Clientes = require("controllers/clientes")
Producto = require("models/producto")
Movimiento = require("models/movimiento")

class Movimientos extends Spine.Controller
  @extend Spine.Controller.ViewDelegation
  
  tag: "tr"

  elements:
    ".validatable" : "inputs_to_validate"

  events:
    "click .js_btn_remove" : "remove"
    "click .js_btn_add" : "add"
    "change input" : "checkItem"
    
  constructor: ->
    super 
    @html require("views/apps/auxiliares/devoluciones/item")(@movimiento) 
    @movimiento.ProductoCantidad = 0
    @checkItem()
    

  checkItem: (e=false) =>
    @updateFromView(@movimiento,@inputs_to_validate)
    @movimiento.updateSubTotal()
    @movimiento.applyDescuento()
    @movimiento.applyImpuesto()
    @movimiento.updateTotal()
    @movimiento.save()
  
  remove: (e) =>
    t = $(e.target)
    parent = t.parents('tr')
    input = parent.find('input')
    input.val(0)
    @checkItem()
  
  add: (e) =>
    t = $(e.target)
    parent = t.parents('tr')
    input = parent.find('input')
    input.val(input.attr("data-max-value"))
    @checkItem()

  reset: ->
    @movimiento.destroy()
    @release()

class Devoluciones extends Spine.Controller
  @extend Spine.Controller.ViewDelegation
  
  @departamento = "Inventarios"
  @label = "Devolucion de Mercaderia"
  @icon = "icon-refresh"
  
  
  className: "row-fluid"

  elements:
    ".movimientos_list" :"movimientos_list"
    ".error" : "error"
    ".validatable" : "inputs_to_validate"
    ".src_cliente" : "src_cliente"
    ".lbl_subTotal" : "lbl_subTotal"
    ".lbl_descuento" : "lbl_descuento"
    ".lbl_impuesto" : "lbl_impuesto"
    ".lbl_total" : "lbl_total"


  events:
    "click .cancel" : "reset"
    "click .save" : "send"

  constructor: ->
    super
    Cliente.reset_current()
    @movimientos = []
    
    @documento = Documento.create {Tipo_de_Documento: "NC"}     
    Movimiento.bind "query_success" , @onLoadMovimientos
    Movimiento.bind "change update" , @onMovimientoChange
    Cliente.bind 'current_set' , @onClienteSet
     
      
    @html require("views/apps/auxiliares/devoluciones/layout")(@constructor)
    @clientes = new Clientes(el: @src_cliente)

  onClienteSet: (cliente) =>
    Movimiento.destroyAll()
    Movimiento.query {cliente: cliente, tipos: ["'FA'"] , estado: "Impreso", diasAtras: "11" }

  onLoadMovimientos: =>
    movimientos = Movimiento.all()
    for movimiento in movimientos
      movimientosRow = new Movimientos(movimiento: movimiento)
      @movimientos.push movimientosRow
      @movimientos_list.append movimientosRow.el

  onMovimientoChange: =>
    @documento.updateFromMovimientos(Movimiento.all())
    @documento.save()
    @lbl_subTotal.html @documento.SubTotal.toMoney()
    @lbl_descuento.html @documento.Descuento.toMoney()
    @lbl_impuesto.html @documento.Impuesto.toMoney()
    @lbl_total.html @documento.Total.toMoney()


  #####
  # ACTIONS
  #####
  
  customValidation: =>
    @validationErrors.push "Escoja al menos un producto" if Movimiento.count() == 0
    @validationErrors.push "Debe escoger un cliente" if Cliente.current == null
    item.checkItem() for item in @movimientos
    
    
  beforeSend: (object) =>
    for movimiento in Movimiento.all()
      movimiento.Tipo             = object.Tipo_de_Documento
      movimiento.Observacion      = object.Observacion
      movimiento.Referencia       = movimiento.CodigoExterno
      movimiento.CodigoExterno    = null
      movimiento.id               = null
      movimiento.Plazo            = 30
      movimiento.updateTotal()
      movimiento.save()

  send: (e) =>
    @refreshElements()
    @updateFromView(@documento,@inputs_to_validate)
    changedMovimientos = []
    for movimiento in Movimiento.all()
      changedMovimientos.push(movimiento) if(movimiento.ProductoCantidad) > 0    
    
      data =
        class: Movimiento
        restData: changedMovimientos

      Spine.trigger "show_lightbox" , "insert" , data , @after_send

  after_send: =>
    @reset(false)

  customReset: ->
    for items in @movimientos
       items?.reset()
    @documento.destroy()
    Movimiento.unbind "query_success" , @onLoadMovimientos
    Movimiento.unbind "change update" , @onMovimientoChange
    Cliente.unbind 'current_set' , @onClienteSet
    

module.exports = Devoluciones
