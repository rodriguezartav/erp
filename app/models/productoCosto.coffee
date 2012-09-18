Spine = require('spine')

class ProductoCosto extends Spine.Model
  @configure 'Producto', "Costo" , "CostoAnterior"

  @extend Spine.Model.SalesforceModel
  @extend Spine.Model.SalesforceAjax

  @overrideName= "Producto"

module.exports = ProductoCosto