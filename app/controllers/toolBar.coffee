Spine = require('spine')
Productos = require("controllers/productos")

class ToolBar  extends Spine.Controller

  elements:
    ".src_productos" : "src_productos"


  constructor: ->
    super
    @html require("views/toolBar/layout")
    new Productos(el: @src_productos)

module.exports = ToolBar
