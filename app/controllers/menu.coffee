Spine = require('spine')

class Menu extends Spine.Controller
 
  className: "menu"
   
  elements:
    ".list" : "list"
 
  events:
    "click .appButton" : "on_click"
  
  constructor: ->
    super
    @render()

  render: =>
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
      @list.append html
  
    #@list.append '<ul class="span2"><li><h2>Notificaciones</h2></li></ul>'
      
  on_click: (e) =>
   target = $(e.target).parents ".menuApp"   
   name = target.attr("data-type")
   target.parent().addClass "active"
   @navigate "/apps/" + name

  reset: =>
   @el.undelegate('ul>li>a', 'click', 'on_click')
   @release()
 
module.exports = Menu
