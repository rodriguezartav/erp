Spine = require('spine')
Menu = require("controllers/menu")
Notificaciones = require("controllers/notificaciones")
  
class Principal extends Spine.Controller

  elements:
    ".menu"     : "menuDiv"
    ".noticationContainer" : "noticationContainer"

  constructor: ->
    super
    @html require("views/controllers/main/layout")
    @notificaciones = new Notificaciones(el: @noticationContainer)
    @menu           = new Menu(el: @menuDiv)

  render: =>
    @menu.render()
    @notificaciones.render()
    @

  reset: =>

class Main extends Spine.Controller

  constructor: ->
    super
    @principal = new Principal()

    @routes
      "/apps": =>
        @currentApp?.reset?()
        @currentApp = @principal.render()
        @el.removeClass "container"
        @el.addClass "container-fluid"
        @html @currentApp

      "/apps/:label": (params) =>
        @currentApp?.reset?()
        for app in Spine.apps
          @currentApp = app if app.label.replace(/\s/g,'') == params.label
        @currentApp = new @currentApp
        @html @currentApp
        @el.addClass "container"
        @el.removeClass "container-fluid"


module.exports = Main
