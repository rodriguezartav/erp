Spine = require('spine')

class Session extends Spine.SingleModel
  @configure "Session" , "instance_url", "token" , "userId",
    "username" , "password" ,"passwordToken" ,
    "user"
    "lastUpdate", "lastLogin"
    "error" , "isOnline"
  


module.exports = Session

