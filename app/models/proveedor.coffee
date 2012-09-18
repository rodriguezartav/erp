Spine = require('spine')

class Proveedor extends Spine.Model
  @configure 'Proveedor', 'Name', 'Codigo','Plazo' ,'Cuenta'


  @extend Spine.Model.SalesforceModel
  @extend Spine.Model.SalesforceAjax if typeof window != 'undefined'
  @extend Spine.Model.SelectableModel if typeof window != 'undefined'


module.exports = Proveedor