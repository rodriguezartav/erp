require('lib/setup')
Spine = require('spine')
Documento = require("models/documento")
Cliente = require("models/cliente")
Clientes = require("controllers/clientes")
Producto = require("models/producto")
Recibo = require("models/recibo")

class ConvertirRecibo extends Spine.Controller
  className: "row"

  elements:
    ".error" : "error"
    ".validatable" : "inputs_to_validate"
    ".src_cliente" : "src_cliente"
    ".item_loader" : "item_loader"
    ".recibos_list" : "recibos_list"

  events:
    "click .cancel" : "reset"
    "click .save" : "send"

  @type = "compras"
  @departamento = "Inventarios"

  constructor: ->
    super
    @error.hide()
    Cliente.cancel()
    Cliente.query({credito:true})      
    @html require("views/apps/auxiliares/convetirRecibos/layout")(@documento)
    new Clientes(el: @src_cliente)
    @item_loader.hide()
    
    Documento.bind "query_success" , @onLoadDocumentos
    Cliente.bind 'current_set' , (cliente) =>
      Recibo.destroyAll()
      Recibo.query {cliente: cliente , listo: true}
      @item_loader.show()

  onLoadDocumentos: =>
    recibos = Recibo.all() 
    @recibos_list.html require("views/apps/auxiliares/convetirRecibos/listos")(recibos) 
    @item_loader.hide()

  cancel: ->
    Recibo.destroyAll()
    Cliente.cancel_current()
    @inputs_to_validate.val("")

  #####
  # ACTIONS
  #####
  
  customValidation: =>
    @validationErrors.push "Ingrese al menos un producto" if Movimiento.count() == 0
    @validationErrors.push "Debe escoger un cliente" if Cliente.current = null
    
  beforeSend: (object) ->
    documentos = []
    for index,value of object
      src = Movimiento.find(index)
      movimiento = {}
      movimiento.Tipo               = "NC"
      movimiento.Cliente            = Cliente.current.id
      movimiento.ProductoPrecio     = src.ProductoPrecio
      movimiento.ProductoCantidad   = value
      movimiento.Impuesto           = src.Impuesto
      movimiento.Descuento          = src.Descuento
      movimiento.Observacion        = object.Observacion
      movimiento.Referencia         = "#{src.CodigoExterno}-src.Id"
    Movimiento.refresh movimientos , clear: true
    
  send: (e) =>
    @documento = Recibo.create {} if !@documento
    @updateFromView(@documento,@inputs_to_validate)
    Spine.trigger "show_lightbox" , "sendRecibos" , Recibo.all() , @after_send   

  after_send: =>
    @cancel()
    
  reset: =>
    @navigate "/apps"
    

module.exports = ConvertirRecibo
