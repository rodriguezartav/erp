Spine = require('spine')

class Notificacion extends Spine.Model
  @configure 'Notificacion' , "image" , "title" ,  "text" , "date" , "status" , "userId"

  @createFromMessage: (image = "images/logo_icon.png" , title , text , notifyBrowser = false  , userId = null) ->
    nots = Notificacion.create 
      date    :   new Date()
      image   :   image
      text    :   text
      title   :   title
      userId  :   userid
      status  :   if notifyBrowser then "pending" else "complete"

  @createForPerfil: (user , text ) ->
    nots = Notificacion.create 
      date    :   new Date()
      image   :   user.SmallPhotoUrl
      title   :   user.Name
      text    :   text
      status  :   "pending"
      userId  :   user.id

module.exports = Notificacion