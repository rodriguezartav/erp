Spine = require('spine')
Notificacion = require "models/notificacion"

class Notificaciones extends Spine.Controller
 
  elements:
    ".feeds_list" : "feeds_list"
    ".profiles_list" : "profiles_list"
    ".dms_list" : "dms_list"
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
    Notificacion.bind "create destroy" , @renderNotificaciones

  render: =>
    feeds = []
    profiles =[]
    dms = []
    
    all = Notificacion.all().sort (a,b) ->
      return b.date.getTime() - a.date.getTime()
  
    for noti in all
      if noti.type == "feed"
        feeds.push noti

      else if noti.type == 'profile'
        profiles.push noti
      
    @hasNots.removeClass "has"
    if feeds.length > 0
      @hasNotFeed.addClass "has" 
      $('.tabHeader .feed').tab('show');

    if profiles.length > 0
      @hasNotProfile.addClass "has"
      $('.tabHeader .profile').tab('show');
    
      

    @feeds_list.html require("views/controllers/notificaciones/notificacion")(feeds)
    @profiles_list.html require("views/controllers/notificaciones/notificacion")(profiles)
      

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
