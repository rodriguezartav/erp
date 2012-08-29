Spine = require('spine')
Feed = require "models/notifications/feed"
Task = require "models/notifications/task"
User = require "models/user"


class Notificaciones extends Spine.Controller
 
  elements:
    ".feeds_list" : "feeds_list"
    ".tasks_list" : "tasks_list"
    ".people_list" : "people_list"
    ".hasNots"     : "hasNots"
    ".hasNots.dm"  :  "nasNotDm"
    ".hasNots.profile"  :  "hasNotProfile"
    ".hasNots.feed"  :  "hasNotFeed"
    
  events:
    "click .notificacion_item" : "onNotificacionItemClick"
    "click .hasNot"      : "onHasNotTabClick"
  
  constructor: ->
    super
    @render()
    Feed.bind "create destroy" , @renderFeeds
    Task.bind "create destroy" , @renderTasks
    User.bind "create change" , @renderPeople
    

  render: =>
    @renderTasks()
    @renderFeeds()
    @renderPeople()


  renderFeeds: =>
    all = Feed.all().sort (a,b) ->
      return b.date.getTime() - a.date.getTime()
    @feeds_list.html require("views/controllers/notificaciones/notificacion")(all)

  renderTasks: =>
    all = Task.all().sort (a,b) ->
      return b.date.getTime() - a.date.getTime()
    @tasks_list.html require("views/controllers/notificaciones/notificacion")(all)

  renderPeople: =>
    online  = []
    for user in User.all()
      online.push user if user.Online
    $(".people_list").html require("views/controllers/notificaciones/user")(online)

  onHasNotTabClick: (e) =>
    target = $(e).target
    target.removeClass "has "

  onNotificacionItemClick: (e) ->
    target = $(e.target).parents ".notificacion_item"   
    target.removeClass "pending"
    notificacion= Notificacion.find target.attr "data-id"
    notificacion.destroy()

  reset: =>
   @release()
 
module.exports = Notificaciones