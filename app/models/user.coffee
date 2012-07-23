Spine = require('spine')

class User extends Spine.Model
  @configure "User", "Name" , "SmallPhotoUrl", "Perfil__c" ,  "FirstName"
  @extend Spine.Model.Salesforce
  
  @standardObject = true

  @avoidQueryList: ["email","token","password","is_visualforce"]
  
  @queryFilter: (options) =>
    filter = ""
    filter = @queryFilterAddCondition(" IsActive = true " , filter)
    filter = @queryFilterAddCondition(" Profile = 'Cobrador' or Profile = 'Vendedor' " , filter) if options.cobrador
    filter

  
module.exports = User