Spine = require('spine')

class Task extends Spine.Model
  @configure 'Task' , "image" , "title" ,  "text" , "date" , "status" , "userId"

  @createFromMessage: (image = "images/logo_icon.png" , title , text , notifyBrowser = false  , userId = null) ->
    nots = Task.create 
      date    :   new Date()
      image   :   image
      text    :   text
      title   :   title
      userId  :   userid
      status  :   if notifyBrowser then "pending" else "complete"

  @createForPerfil: (user , text , notifyBrowser = false ) ->
    nots = Task.create 
      date    :   new Date()
      image   :   user.SmallPhotoUrl
      title   :   user.Name
      type    :   "profile"
      text    :   text
      status  :   if notifyBrowser then "pending" else "complete"
      userId  :   user.id


  @createForFeed: (user , text , notifyBrowser = false ) ->
    nots = Task.create 
      date    :   new Date()
      image   :   user.SmallPhotoUrl
      title   :   user.Name
      text    :   text
      type    :   "feed"
      status  :   if notifyBrowser then "pending" else "complete"
      userId  :   user.id

module.exports = Task