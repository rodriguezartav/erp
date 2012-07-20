Spine = require('spine')

class Menu extends Spine.Controller
 
  className: "menu"
   
  elements:
    "ul" : "list"
    "li" : "items"
 
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
      @list.append require("views/controllers/menu/header")(name: index)
      for app in value
        html = require("views/controllers/menu/app")(app: app , header: index)
        @list.append html

  
      
  on_click: (e) =>
   target = $(e.target).parents "li"
   
   name = target.attr("data-type")
   @items.removeClass "active"
   target.parent().addClass "active"
   @navigate "/apps/" + name

  reset: =>
   @el.undelegate('ul>li>a', 'click', 'on_click')
   @release()
 
module.exports = Menu
