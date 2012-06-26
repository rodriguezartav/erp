Spine = require('spine')

class Cierre extends Spine.Model
  @configure "Cierre" , "Name" , "Tipo" , "Fecha" , "Data"
 
  @extend Spine.Model.Salesforce
  
    
module.exports = Cierre

