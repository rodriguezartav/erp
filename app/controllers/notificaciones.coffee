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
    Feed.bind "create" , @renderFeeds
    User.bind "change" , @renderPeople

  render: =>
    @renderPeople()

  renderFeeds: (feed) =>
    user = User.find feed.userId
    user.Status = feed.text
    user.LastUpdate = new Date();
    user.save()

  renderPeople: =>
    online  = []
    for user in User.all()
      online.push user 
      
    online.sort (a,b) ->
      return b.getLastUpdate() - a.getLastUpdate()

    $(".people_list").html require("views/controllers/notificaciones/user")(online)

  reset: =>
   @release()
 
module.exports = Notificaciones