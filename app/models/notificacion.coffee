Spine = require('spine')

class Notificacion extends Spine.Model
  @configure 'Notificacion' , "text" , "date"
  
module.exports = Notificacion