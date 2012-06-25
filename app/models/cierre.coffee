Spine = require('spine')

class Cierre extends Spine.Model
  @configure "Cierre" , "Name" , "Tipo" , "Date"
 
  @extend Spine.Model.Salesforce
  
    
module.exports = Cierre

