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

class Lightbox extends Spine.Controller
  className: 'lightbox reveal-modal-bg'

  constructor: ->
    super
    @items = [Login , SendDocumento , SendMovimientos , SendCierre,CierreManual,SendRecibo]
    
    Spine.bind "hide_lightbox" , @hide
    
    Spine.bind "show_lightbox" , ( type , data =null, callback=null ) =>
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