Spine = require('spine')
Feed = require "models/notifications/feed"
Task = require "models/notifications/task"
User = require "models/user"
ChatterFeed= require "models/chatterFeed"

class Notificaciones extends Spine.Controller
 
  elements:
    ".feed_list" : "feed_list"
    ".tasks_list" : "tasks_list"
    ".people_list" : "people_list"
    ".hasNots"     : "hasNots"
    ".hasNots.dm"  :  "nasNotDm"
    ".hasNots.profile"  :  "hasNotProfile"
    ".hasNots.feed"  :  "hasNotFeed"
    ".txt_createFeed" : "txt_createFeed"
    
  events:
    "click .btn_sendFeed" : "onBtnSendFeed"
    "click .btn_leerMas": "onBtnLeerMas"
    "click .feedBody" : "onFeedBodyClick"
  
  constructor: ->
    super
    @html require("views/controllers/notificaciones/layout")()
    User.bind "change" , @renderPeople
    ChatterFeed.bind "refresh" , @onRenderFeed

  render: =>
    @renderPeople()

  onRenderFeed: =>
    @feed_list.html ""
    feeds = ChatterFeed.all()
    feeds = feeds.sort (a,b) =>
      return Date.parse(b.CreatedDate) - Date.parse(a.CreatedDate)
      
    for feed in feeds
      user = User.exists feed.CreatedByid
      if user
        html = require("views/controllers/notificaciones/notificacion")(user:user , feed: feed)
        @feed_list.append html


  renderPeople: =>
    online  = []
    for user in User.all()
      online.push user  if user.Online
      
    online.sort (a,b) ->
      return b.getLastUpdate() - a.getLastUpdate()

    $(".people_list").html require("views/controllers/notificaciones/user")(online)


  onFeedBodyClick: (e) =>
    target = $(e.target)
    target = target.parent() until target.hasClass "feedBody"
    if target.html().length > 150
      body = target.data("body").substring(0,150) + '... <a class="strong btn_leerMas">leer mas</a>'
      target.html body

  onBtnLeerMas: (e) =>
    target = $(e.target)
    p = target.parent()
    p.html p.data("body")
    return false


  onBtnSendFeed: =>
    data =
      class: ChatterFeed
      restRoute: "QuePasoHoy"
      restMethod: "POST"
      restData: 
        quePaso: @txt_createFeed.val()

    Spine.trigger "show_lightbox" , "rest" , data , @after_send
    
  after_send: =>
    ChatterFeed.ajax().query()
    @txt_createFeed.val ""

  reset: =>
    ChatterFeed.unbind "refresh" , @onRenderFeed  
    User.unbind "change" , @renderPeople
    @release()
 
module.exports = Notificaciones