Spine   = require('spine')
User = require('models/user')
Cliente = require('models/cliente')
Login = require("controllers/lightbox/login")
$       = Spine.$

class Lightbox extends Spine.Controller
  className: 'lightbox reveal-modal-bg'

  constructor: ->
    super
    @items = [new Login]
    
    Spine.bind "hide_lightbox" , @hide
    
    Spine.bind "show_lightbox" , ( type , data =null, callback=null ) =>
      @el.show()
      @current = null
      for item in @items
        @current = item if item.el.hasClass type
      if @current
        @current.render(data,callback)
        @html @current

  hide: =>
    @current = null
    @el.empty()
    @el.hide()

module.exports = Lightbox