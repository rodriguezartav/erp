Spine = require('spine')
Notificacion = require "models/notificacion"

class Menu extends Spine.Controller
 
  className: "menu"
   
  elements:
    ".menuContainer"     : "menuContainer"
    ".feeds_list" : "feeds_list"
    ".profiles_list" : "profiles_list"
    ".dms_list" : "dms_list"
    ".hasNots"     : "hasNots"
    ".hasNots.dm"  :  "nasNotDm"
    ".hasNots.profile"  :  "hasNotProfile"
    ".hasNots.feed"  :  "hasNotFeed"
    
  events:
    "click .appButton" : "on_click"
    "click .notificacion_item" : "onNotificacionItemClick"
    "click .hasNot"      : "onHasNotTabClick"
  
  constructor: ->
    super
    @renderApps()
    @renderNotificaciones()
    Notificacion.bind "create destroy" , @renderNotificaciones

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
  

  renderNotificaciones: =>
    feeds = []
    profiles =[]
    dms = []
    
    all = Notificacion.all().sort (a,b) ->
      return b.date.getTime() - a.date.getTime()
  
    console.log all
    for noti in all
      if noti.type == "feed"
        feeds.push noti
      else if noti.type == 'profile'
        profiles.push noti
      else if noti.type == 'dm'
        dms.push noti
      
    @hasNots.removeClass "has"
    

    if feeds.length > 0
      @hasNotFeed.addClass "has" 
      $('.tabHeader .feed').tab('show');

    if profiles.length > 0
      @hasNotProfile.addClass "has"
      $('.tabHeader .profile').tab('show');
    
    if dms.length > 0
      @hasNotDm.addClass "has" 
      $('.tabHeader .dm').tab('show');
      

    @feeds_list.html require("views/controllers/menu/notificacion")(feeds)
    @dms_list.html require("views/controllers/menu/notificacion")(dms)
    @profiles_list.html require("views/controllers/menu/notificacion")(profiles)
      
  on_click: (e) =>
   target = $(e.target).parents ".menuApp"   
   name = target.attr("data-type")
   target.parent().addClass "active"
   @navigate "/apps/" + name

  onHasNotTabClick: (e) =>
    target = $(e).target
    target.removeClass "has "

  onNotificacionItemClick: (e) ->
    target = $(e.target).parents ".notificacion_item"   
    target.removeClass "pending"
    notificacion= Notificacion.find target.attr "data-id"
    notificacion.destroy()

  reset: =>
   @el.undelegate('ul>li>a', 'click', 'on_click')
   @release()
 
module.exports = Menu
