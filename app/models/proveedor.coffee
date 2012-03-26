Spine = require('spine')

class Proveedor extends Spine.Model
  @configure 'Proveedor', 'Name', 'Codigo'
  @extend Spine.Model.Salesforce
  @extend Spine.Model.SelectableModel

  @avoidQueryList= []

        
module.exports = Proveedor