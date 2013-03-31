Spine = require('spine')

class ClienteFeed extends Spine.Model
  @configure 'Cliente__Feed', 'Body' , "ParentId"

  @extend Spine.Model.SalesforceModel
  @extend Spine.Model.SalesforceAjax.Methods

  @queryFilter: (options) =>
    return "" if !options
    filter = ""
  #  filter = @queryFilterAddCondition(" Activo__c != 0"                                 , filter) if options.activo
    filter



module.exports = ClienteFeed