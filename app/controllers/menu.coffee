Spine = require('spine')
Notificacion = require "models/notificacion"

class Menu extends Spine.Controller
   
  elements:
    ".menuContainer"     : "menuContainer"

  constructor: ->
    super

  render: =>
    @menuContainer.empty()
    group = {}
    for app in Spine.apps
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

    @el.find('.appButton').one "click" ,  @on_click


  on_click: (e) =>
    target = $(e.target).parents ".menuApp"   
    name = target.attr("data-type")
    target.parent().addClass "active"
    @navigate "/apps/" + name
 
module.exports = Menu
