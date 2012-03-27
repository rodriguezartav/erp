require('lib/setup')
Spine = require('spine')
Documento = require("models/documento")
Cliente = require("models/cliente")
Clientes = require("controllers/clientes")
Producto = require("models/producto")
Movimiento = require("models/movimiento")

class Devoluciones extends Spine.Controller
  @extend Spine.Controller.ViewDelegation
  
  @departamento = "Inventarios"
  @label = "Devolucion de Mercaderia"
  
  className: "row"

  elements:
    ".movimientos_list" :"movimientos_list"
    ".error" : "error"
    ".validatable" : "inputs_to_validate"
    ".src_cliente" : "src_cliente"
    ".cantidadADevolver" : "cantidadADevolver"
    ".item_loader" : "item_loader"
    ".btn" : "buttons"

  events:
    "click .cancel" : "reset"
    "click .save" : "send"
    "click .cantidadADevolver" : "on_cantidadADevolver_click"

  @type = "compras"
  @departamento = "Inventarios"

  constructor: ->
    super
    @error.hide()
    Cliente.cancel_current()
    
    Cliente.bind 'current_set' , (cliente) =>
      Movimiento.destroyAll()
      Movimiento.query {cliente: cliente, tipos: ["'FA'"] }
      @item_loader.show()
      
    Movimiento.bind "query_success" , @onLoadMovimientos
    @render()
  
  render: =>  
    @html require("views/apps/auxiliares/devoluciones/layout")()
    @clientes = new Clientes(el: @src_cliente)
    @item_loader.hide()

  onLoadMovimientos: =>
    @item_loader.hide()
    movimientos = Movimiento.all()
    for movimiento in movimientos
      movimiento.ProductoName = Producto.find(movimiento.Producto).Name
    @movimientos_list.html require("views/apps/auxiliares/devoluciones/itemToReturn")(movimientos) 

  on_cantidadADevolver_click: (e) =>
    target = $(e.target)
    movimiento = Movimiento.find( target.attr("data-type") )
    if target.val() == "" or target.val() == "0"
      target.val movimiento.ProductoCantidad

  #####
  # ACTIONS
  #####
  
  customValidation: =>
    @validationErrors.push "Escoja al menos un producto" if Movimiento.count() == 0
    @validationErrors.push "Debe escoger un cliente" if Cliente.current == null
    
  beforeSend: (object) =>
    movimientos = []
    for index,value of object
      src = Movimiento.exists(index)
      if src
        movimiento = {}
        movimiento.Tipo               = "NC"
        movimiento.Cliente            = src.Cliente
        movimiento.ProductoPrecio     = src.ProductoPrecio
        movimiento.ProductoCantidad   = value
        movimiento.ProductoCosto      = src.ProductoCosto
        movimiento.Impuesto           = src.Impuesto
        movimiento.Descuento          = src.Descuento
        movimiento.Observacion        = object.Observacion
        movimiento.Referencia         = "#{src.CodigoExterno}-src.Id"
        movimientos.push movimiento if value != 0
        Movimiento.update_total(movimiento)
    Movimiento.refresh movimientos , clear: true

  send: (e) =>
    @documento = {Tipo_de_Documento: "NC"} if !@documento
    @refreshElements()
    @updateFromView(@documento,@inputs_to_validate)
    Spine.trigger "show_lightbox" , "sendMovimientos" , Movimiento.all() , @after_send   
    @buttons.hide()
    Spine.one "hide_lightbox" , =>
      @buttons.show()

  after_send: =>
    @reset(false)

  customReset: ->
    Cliente.cancel_current()
    @documento=null 
    Movimiento.destroyAll()
    @movimientos_list.empty()
    

module.exports = Devoluciones
