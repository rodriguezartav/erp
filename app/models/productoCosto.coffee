Spine = require('spine')

class ProductoCosto extends Spine.Model
  @configure 'Producto', "Costo" , "CostoAnterior"

  @extend Spine.Model.Salesforce

  @overrideName= "Producto"

module.exports = ProductoCosto