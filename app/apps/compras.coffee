require('lib/setup')
Spine = require('spine')
Clientes = require("controllers/clientes")
Productos = require("controllers/productos")
Documento = require("models/documento")
Cliente = require("models/cliente")
Producto = require("models/producto")
Cuenta = require("models/cuenta")
User = require("models/user")

class Compras extends Spine.Controller
  className: "row"

  elements:
    ".forma_pago>.list" : "forma_pago_list"
    ".forma_pago>.total" : "forma_pago_total"
    ".saldos_pendientes .list" :"saldos_pendientes_list"
    ".saldos_pendientes>.total" : "saldos_pendientes_total"
    ".src_cliente" : "src_cliente"

  events:
    "click .btn_forma" : "forma_pago_add_item"
    "click .remove_forma_pago" : "forma_pago_remove_item"
    "click .btn_apply_deposito" : "saldos_pendientes_update_total_apply_deposito"
    "change input.txt_forma_pago_monto" : "forma_pago_update_total"
    "change input.txt_saldo_pendiente_monto" : "saldos_pendientes_update_total"

  constructor: ->
    super
    Cliente.fetch_from_sf(User.current)
    Producto.fetch_from_sf(User.current)
    @clientes_searchbox = new Clientes
    
    @html require("views/apps/compras/landing")
    Documento.bind "refresh" , @render_documentos
    @total_depositos = 0
    Cliente.reset_current()
    Cliente.bind 'refresh' , =>
      @html require("views/apps/compras/layout")
      @src_cliente.append @clientes_searchbox.el
      



module.exports = Compras





