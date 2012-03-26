require('lib/setup')
Spine = require('spine')
Documento = require("models/documento")
Cliente = require("models/cliente")
Clientes = require("controllers/clientes")
Producto = require("models/producto")
Recibo = require("models/recibo")

class EmitirRecibosRemotos extends Spine.Controller
  className: "row"

  elements:
    ".error" : "error"
    ".validatable" : "inputs_to_validate"
    ".src_cliente" : "src_cliente"
    ".item_loader" : "item_loader"
    ".documentos_list" : "documentos_list"

  events:
    "click .cancel" : "cancel"
    "click .save" : "send"
    "click .txt_saldo_pendiente_monto" : "on_saldo_click"
    "change .txt_saldo_pendiente_monto" : "on_saldo_change"
    

  constructor: ->
    super
    @error.hide()
    Cliente.reset()
    Cliente.query({credito:true})      
    @html require("views/apps/auxiliares/emitirRecibo/layout")(@documento)
    new Clientes(el: @src_cliente)
    @item_loader.hide()
    
    
    Documento.bind "query_success" , @onLoadDocumentos
    Cliente.bind 'current_set' , (cliente) =>
      Documento.destroyAll()
      Documento.query {cliente: cliente,saldo: true}
      @item_loader.show()
      

  onLoadDocumentos: =>
    documentos = Documento.all() 
    @documentos_list.html require("views/apps/auxiliares/emitirRecibo/saldo")(documentos) 
    @item_loader.hide()
    

  on_saldo_click: (e) =>
    target = $(e.target)
    documento = Documento.find(target.attr("data-id"))
    target.val documento.Saldo

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

  cancel: ->
    Documento.destroyAll()
    Cliente.reset_current()
    @inputs_to_validate.val("")

module.exports = EmitirRecibosRemotos
