Spine = require('spine')

class User extends Spine.Model
  @configure "User", "Name" , "SmallPhotoUrl", "Perfil" ,  "FirstName" , "Online"
  @extend Spine.Model.SalesforceModel
  
  @standardObject = true

  @queryFilter: (options) =>
    filter = ""
    filter = @queryFilterAddCondition(" IsActive = true " , filter)
    filter = @queryFilterAddCondition(" Profile = 'Cobrador' or Profile = 'Vendedor' " , filter) if options.cobrador
    filter

module.exports = User