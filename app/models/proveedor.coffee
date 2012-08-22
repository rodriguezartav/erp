Spine = require('spine')

class Proveedor extends Spine.Model
  @configure 'Proveedor', 'Name', 'Codigo','Plazo' ,'Cuenta'


  @extend Spine.Model.SalesforceModel
  @extend Spine.Model.SalesforceAjax
  
  @extend Spine.Model.SelectableModel

        
module.exports = Proveedor