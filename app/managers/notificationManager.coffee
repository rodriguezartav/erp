Spine = require('spine')

class NotificationManager
  
  constructor: ->

  checkPermision: ->
    if window.webkitNotifications?.checkPermission?() != 0
      window.webkitNotifications?.requestPermission?()

  showNotification: (title,message) =>
    @notification =  {title: title,message:message}
    @notificationTimer = window.setTimeout @showNotifications , 4000 if !@notificationTimer

  showNotifications: =>
    notificacion = window.webkitNotifications.createNotification "" , @notification.title , @notification.message
    notificacion.show()
    @notificationTimer = null

module.exports = NotificationManager