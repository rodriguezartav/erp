Spine = require('spine')
Notificacion = require "models/notificacion"

class NotificationManager
  
  constructor: ->
    setInterval @showNotification , 45000

  showNotification: () =>
    return false
    
  otherFun: ->
    pendingNotifications = Notificacion.findAllByAttribute "status" , "pending"
    return false if pendingNotifications.length == 0
    return false if @notificacion
    
    @notificacion = window?.webkitNotifications?.createNotification "http://rodcoerp.herokuapp.com/images/logo_icon.png" 
    , "Notificaciones Pendientes" , "Hay #{pendingNotifications.length} notificacion/es pendientes, de click en cada una para completarlas."
    
    @notificacion.show()
    setTimeout =>
      @notificacion.close() 
      @notificacion = null
      8000

module.exports = NotificationManager