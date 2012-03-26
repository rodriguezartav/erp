Spine = require('spine')

class Error extends Spine.Model
  @configure "Error" , "Location" , "Class" ,  "Details"

 

module.exports = Error

