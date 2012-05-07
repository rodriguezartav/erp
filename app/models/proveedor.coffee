Spine = require('spine')

class Proveedor extends Spine.Model
  @configure 'Proveedor', 'Name', 'Codigo','Plazo'
  @extend Spine.Model.Salesforce
  @extend Spine.Model.SelectableModel

        
module.exports = Proveedor