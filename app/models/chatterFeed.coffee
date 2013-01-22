Spine = require('spine')

class ChatterFeed extends Spine.Model
  @configure 'ChatterFeed' , "Body" , "CreatedById"  , "CreatedDate"

  @extend Spine.Model.SalesforceModel
  @extend Spine.Model.SalesforceAjax.Methods
  
  @overrideName = "CollaborationGroupFeed"
  @standardObject = true
  
  @queryFilter: (options ) =>
    filter =""
    filter = @queryFilterAddCondition(" CreatedDate = LAST_N_DAYS:2" , filter)
    filter = @queryOrderAddCondition( " ORDER BY CreatedDate DESC ", filter)
    filter

module.exports = ChatterFeed