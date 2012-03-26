Spine = require('spine')


class Menu extends Spine.Controller

  elements:
    "ul" : "list"

  events:
    "click ul>li>a" : "on_click"
  
  constructor: ->
    super
    @render()

  render: =>
    @html require("views/menu/layout")
    group = {}
    for app in @apps
      appList = group[app.departamento] || []
      appList.push app
      group[app.departamento] = appList
    
    for index,value of group
      @list.append require("views/menu/header")(name: index)
      for app in value
        @list.append require("views/menu/app")(app)
   
   on_click: (e) =>
     target = $(e.target)
     name = target.attr("data-type")
     @navigate "/apps/" + name

   reset: =>
     @release()
   
module.exports = Menu
