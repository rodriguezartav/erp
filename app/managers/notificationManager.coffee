Spine = require('spine')

class NotificationManager
  
  constructor: ->

  checkPermision: ->
    if window.webkitNotifications?.checkPermission?() != 0
      window.webkitNotifications?.requestPermission?()

  showNotification: (title,message) =>
    return false if @notificationObj?.title == title
    @notificationObj =  {title: title,message:message}
    @notificacion = window?.webkitNotifications?.createNotification "http://rodcoerp.herokuapp.com/images/logo_icon.png" , @notificationObj.title , @notificationObj.message
    @notificacion.show()
    setTimeout =>
      @notificacion.close() 
      4000

module.exports = NotificationManager