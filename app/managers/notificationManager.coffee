Spine = require('spine')
FayeManager = require("managers/fayeManager")

class NotificationManager
  
  constructor: ->
    @fayeManager = new FayeManager()
    @checkPermision()
    
    #window.setInterval( @checkOverallStatus , 60000 )
    

  checkPermision: ->
    if window.webkitNotifications?.checkPermission?() != 0
      window.webkitNotifications?.requestPermission?();


  checkOverallStatus: ->
    

  
module.exports = NotificationManager