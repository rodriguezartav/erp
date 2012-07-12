Spine = require('spine')

class NotificationManager
  
  constructor: ->

  checkPermision: ->
    if window.webkitNotifications?.checkPermission?() != 0
      window.webkitNotifications?.requestPermission?()

  showNotification: (title,message) =>
    notificationObj =  {title: title,message:message}
    notificacion = window?.webkitNotifications?.createNotification "http://rodcoerp.herokuapp.com/images/logo_icon.png" , notificationObj.title , notificationObj.message
    notificacion.show()

module.exports = NotificationManager