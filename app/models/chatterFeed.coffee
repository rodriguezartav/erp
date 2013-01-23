Spine = require('spine')

class ChatterFeed extends Spine.Model
  @configure 'ChatterFeed' , "Body" , "CreatedById"  , "CreatedDate"

  @extend Spine.Model.SalesforceModel
  @extend Spine.Model.SalesforceAjax.Methods
  @extend Spine.Model.SocketModel
  
  
  @overrideName = "CollaborationGroupFeed"
  @standardObject = true
  @autoQueryTimeBased = true
  @autoQuery =true;
  
  @queryFilter: (options ) =>
    filter =""
    filter = @queryFilterAddCondition(" CreatedDate = LAST_N_DAYS:2" , filter)
    filter = @queryOrderAddCondition( " ORDER BY CreatedDate DESC ", filter)
    filter

module.exports = ChatterFeed