Spine = require('spine')

class Cuenta extends Spine.Model
  @configure "Cuenta" , "Name" , "Codigo" , "Automatica"
  @extend Spine.Model.Salesforce

  @queryFilter: (options) =>
    return "" if !options
    filter = "where Clase__c IN (#{options.clases})"

 

module.exports = Cuenta

