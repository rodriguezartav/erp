Spine = require('spine')
User = require "models/user"

class Notificacion extends Spine.Model
  @configure 'Notificacion' , "text" , "date" , "user" , "status"

  @createFromMessage: ( message , text , notifyBrowser = false ) ->
    user = User.exists message.user
    user = {Name: "Auto Servicio" , SmallPhotoUrl: "images/logo_icon.png" } if !user
    nots = Notificacion.create 
      date:   new Date(), 
      text:   text
      user:   user
      status: if notifyBrowser then "pending" else "complete"

module.exports = Notificacion