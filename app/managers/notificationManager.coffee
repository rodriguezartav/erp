Spine = require('spine')
Notificacion = require "models/notificacion"

class NotificationManager
  
  constructor: ->
    setInterval @showNotification , 60000

  checkPermision: ->
    if window.webkitNotifications?.checkPermission?() != 0
      window.webkitNotifications?.requestPermission?()

  showNotification: () =>
    pendingNotifications = Notificacion.findAllByAttribute "status" , "pending"
    return false if pendingNotifications.length == 0
    return false if @notificacion
    
    @notificacion = window?.webkitNotifications?.createNotification "http://rodcoerp.herokuapp.com/images/logo_icon.png" 
    , "Notificaciones Pendientes" , "Hay #{pendingNotifications.length} notificaciones pendientes, de click en cada una para completarlas."
    
    @notificacion.show()
    setTimeout =>
      @notificacion.close() 
      @notificacion = null
      4000

module.exports = NotificationManager