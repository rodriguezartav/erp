Spine = require('spine')

class Cuenta extends Spine.Model
  @configure "Cuenta" , "Name" , "Codigo"
  @extend Spine.Model.Salesforce

  @queryFilter: (options) =>
    return "" if !options
    filter = "where Tipo__c in (#{options.tipos})"

 

module.exports = Cuenta

