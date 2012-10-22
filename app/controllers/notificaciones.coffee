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
    User.bind "create change" , @renderPeople

  render: =>
    @renderFeeds()
    @renderPeople()


  renderFeeds: (feed) =>
    

  renderPeople: =>
    online  = []
    for user in User.all()
      online.push user if user.Active
    $(".people_list").html require("views/controllers/notificaciones/user")(online)

  reset: =>
   @release()
 
module.exports = Notificaciones