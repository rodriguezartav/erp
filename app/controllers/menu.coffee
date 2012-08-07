Spine = require('spine')
Notificacion = require "models/notificacion"

class Menu extends Spine.Controller
 
  className: "menu"
   
  elements:
    ".menuContainer"     : "menuContainer"
    ".notificacion_list" : "notificacion_list"
 
  events:
    "click .appButton" : "on_click"
  
  constructor: ->
    super
    @renderApps()
    Notificacion.bind "create" , @onNotificacionCreate

  renderApps: =>
    @html require("views/controllers/menu/layout")(apps: @apps)

    group = {}
    for app in @apps
      appList = group[app.departamento] || []
      appList.push app
      group[app.departamento] = appList

    for index,value of group
      html = '<ul class="row-fluid unstyled appList">'
      html += require("views/controllers/menu/header")(name: index)
      for app in value
        html += require("views/controllers/menu/app")(app: app , header: index)
      html += "</ul>"
      @menuContainer.append html
  

  onNotificacionCreate: =>
    nots = Notificacion.all()
    nots.sort (a,b) ->
      return b.date.getTime() - a.date.getTime()
    @notificacion_list.html require("views/controllers/menu/notificacion")(nots)
      
  on_click: (e) =>
   target = $(e.target).parents ".menuApp"   
   name = target.attr("data-type")
   target.parent().addClass "active"
   @navigate "/apps/" + name

  reset: =>
   @el.undelegate('ul>li>a', 'click', 'on_click')
   @release()
 
module.exports = Menu
