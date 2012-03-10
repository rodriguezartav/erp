require('lib/setup')
Spine = require('spine')

Cliente = require("models/cliente")
Pagos = require("controllers/pagos")
Estados = require("controllers/estados")
Ajustes = require("controllers/ajustes")
Documento = require("models/documento")
User = require("models/user")
  

class Main extends Spine.Controller
  className: "columns nine"

  elements:
    ".content" : "content"
    ".alert_wrapper"   :  "alert"

  events:
    "click a.js_view_selector" : "on_view_selected"
    "click .nav_tabs" : "on_tab_click"

  constructor: ->
    super
    @html require("views/main/layout")
    @on_view_reset()

  on_view_reset: =>
    Cliente.reset_current()
    @content.html require("views/main/landing")

  on_view_selected: (e) =>
    return @show_alert("Debe seleccionar un cliente") if Cliente.current == null
    target = $(e.target)
    parent = target.parent()
    type = target.attr "data-type"
    @prepare_view(parent)
    @show_view(type)

  prepare_view: (parent) ->
    parent.toggleClass("active")
    parent.siblings().removeClass("active")
    Documento.fetch_from_sf(Cliente.current,User.current) if !Cliente.locked
    Cliente.locked = true
    
  show_view: (type) =>
    return @on_view_reset() if type == ""
    @current.release() if @current
    @current = new Pagos if type == "pagos"
    @current = new Estados if type == "estados"
    @current = new Ajustes if type == "ajustes"
    @content.html @current.el

  show_alert: (str) =>
    @alert.html require("views/alert")({ message: str })

module.exports = Main
