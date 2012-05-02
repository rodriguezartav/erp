Spine = require('spine')


class NotificationManager
  
  constructor: ->
    @checkPermision()
    
    #window.setInterval( @checkOverallStatus , 60000 )
    

  checkPermision: ->
    if window.webkitNotifications?.checkPermission?() != 0
      window.webkitNotifications?.requestPermission?();


  checkOverallStatus: ->
    

  
module.exports = NotificationManager