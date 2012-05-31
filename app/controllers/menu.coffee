Spine = require('spine')


class Menu extends Spine.Controller

  elements:
    "ul" : "list"
    "li" : "items"
 
  events:
    "click ul>li>a" : "on_click"
  
  constructor: ->
    super
    @render()

  render: =>
    @html require("views/controllers/menu/layout")
    group = {}
    for app in @apps
      appList = group[app.departamento] || []
      appList.push app
      group[app.departamento] = appList
    
    console.log group
    for index , value of group
      @list.append require("views/controllers/menu/header")(name: index)
      for app in value
        console.log app
        @list.append require("views/controllers/menu/app")(app)
   
   on_click: (e) =>
     target = $(e.target)
     name = target.attr("data-app")
     @items.removeClass "active"
     target.parent().addClass "active"
     @navigate "/apps/" + name

   reset: =>
     @release()
   
module.exports = Menu
