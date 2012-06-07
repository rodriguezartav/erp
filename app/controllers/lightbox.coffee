Spine   = require('spine')
$       = Spine.$

User = require('models/user')
Cliente = require('models/cliente')

Login = require("controllers/lightbox/login")

AprobarPedidos = require("controllers/lightbox/aprobarPedidos")

ShowWarning = require("controllers/lightbox/showWarning")
ShowError = require("controllers/lightbox/showError")


Rest = require("controllers/lightbox/rest")
Update = require("controllers/lightbox/update")
Insert = require("controllers/lightbox/insert")


class Lightbox extends Spine.Controller
  className: 'lightbox reveal-modal-bg'

  constructor: ->
    super
    @items = [Insert,Update,Rest,ShowError , ShowWarning , Login , AprobarPedidos ]
    
    Spine.bind "hide_lightbox" , @hide
    
    Spine.bind "show_lightbox" , ( type , data =null , callback=null ) =>
      @el.show()      
      @current = null
      for item in @items
        @current = item if item.type == type
      if @current
        @current = new @current(data: data, callback: callback)
        @html @current

  hide: (delay=false) =>
    if delay
      @el.fadeOut(1800,@doHide)
    else
      @doHide()
 
  doHide: =>
    @current?.release?()
    @current = null
    @el.empty()
    @el.hide()

module.exports = Lightbox