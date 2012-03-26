Spine = require('spine')

class User extends Spine.Model
  @configure "User", "Name" , "email" , "token" , "password" , "is_visualforce"
  @extend Spine.Model.Salesforce
  
  @standardObject = true

  @avoidQueryList: ["email","token","password","is_visualforce"]
  
  @queryFilter: (options) =>
    return "" if !options
    filter = ""
    filter = @queryFilterAddCondition(" Active = true " , filter)
    filter = @queryFilterAddCondition(" Profile = 'Cobrador' or Profile = 'Vendedor' " , filter) if options.cobrador
    filter

  
module.exports = User