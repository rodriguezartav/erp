Spine = require('spine')

class User extends Spine.Model
  @configure "User", "Name" , "SmallPhotoUrl", "Perfil" ,  "FirstName" , "Online"  , "Status" , "LastUpdate"
  @extend Spine.Model.SalesforceModel
  
  @standardObject = true

  @queryFilter: (options) =>
    filter = ""
    filter = @queryFilterAddCondition(" IsActive = true " , filter)
    filter = @queryFilterAddCondition(" Profile = 'Cobrador' or Profile = 'Vendedor' " , filter) if options.cobrador
    filter

  getLastUpdate: =>
    return new Date(Date.parse("1970-1-1")) if !@LastUpdate
    return @LastUpdate

module.exports = User