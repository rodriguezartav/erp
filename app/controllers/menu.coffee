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
    
    console.log group
    for index,value of group
      html = '<ul class="thumbnails span2">'
      html += require("views/controllers/menu/header")(name: index)
      for app in value
        html += require("views/controllers/menu/app")(app: app , header: index)
      html += "</ul>"
      @list.append html
  
      
  on_click: (e) =>
   target = $(e.target).parents ".thumbnail"   
   name = target.attr("data-type")
   target.parent().addClass "active"
   @navigate "/apps/" + name

  reset: =>
   @el.undelegate('ul>li>a', 'click', 'on_click')
   @release()
 
module.exports = Menu
