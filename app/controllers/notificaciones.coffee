Spine = require('spine')
Feed = require "models/notifications/feed"
Task = require "models/notifications/task"
People = require "models/notifications/people"


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
    People.bind "create destroy" , @renderPeople
    Task.bind "create destroy" , @renderTasks
    

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
    all = People.all().sort (a,b) ->
      return b.date.getTime() - a.date.getTime()
    @people_list.html require("views/controllers/notificaciones/notificacion")(all)

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