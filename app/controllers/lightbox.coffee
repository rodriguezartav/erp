Spine   = require('spine')
$       = Spine.$

User = require('models/user')
Cliente = require('models/cliente')

Login = require("controllers/lightbox/login")
SendMovimientos = require("controllers/lightbox/sendMovimientos")
SendDocumento = require("controllers/lightbox/sendDocumento")
SendRecibo = require("controllers/lightbox/sendRecibo")
SendCierre = require("controllers/lightbox/sendCierre")
CierreManual = require("controllers/lightbox/cierreManual")
SendPedidos = require("controllers/lightbox/sendPedidos")
SendPagos = require("controllers/lightbox/sendPagos")

SendDevoluciones = require("controllers/lightbox/sendDevoluciones")

AnularPagos = require("controllers/lightbox/anularPagos")


SendCuentaPorPagar = require("controllers/lightbox/sendCuentaPorPagar")


AprobarPedidos = require("controllers/lightbox/aprobarPedidos")
AprobarRecibos = require("controllers/lightbox/aprobarRecibos")
ConvertirRecibos = require("controllers/lightbox/convertirRecibos")

AnularDocumento = require("controllers/lightbox/anularDocumento")

PagoProveedor = require("controllers/lightbox/sendPagoProveedor")

ShowWarning = require("controllers/lightbox/showWarning")
ShowError = require("controllers/lightbox/showError")


class Lightbox extends Spine.Controller
  className: 'lightbox reveal-modal-bg'

  constructor: ->
    super
    @items = [AnularPagos,ShowError,SendDevoluciones,SendCuentaPorPagar , ShowWarning , Login ,PagoProveedor, SendDocumento , SendPagos , SendMovimientos , SendCierre,CierreManual,SendRecibo,SendPedidos , AprobarPedidos ,AprobarRecibos, ConvertirRecibos,AnularDocumento]
    
    Spine.bind "hide_lightbox" , @hide
    
    Spine.bind "show_lightbox" , ( type , data =null , callback=null ) =>
      @el.show()      
      @current = null
      for item in @items
        @current = item if item.type == type
      if @current
        @current = new @current(data: data, callback: callback)
        @html @current

  hide: =>
    @current?.release?()
    @current = null
    @el.empty()
    @el.hide()

module.exports = Lightbox