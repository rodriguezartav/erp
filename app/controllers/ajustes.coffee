require('lib/setup')
Spine = require('spine')

class Ajustes extends Spine.Controller
  className: "ajustes"

  constructor: ->
    super
    @html require("views/main/ajustes/layout")

module.exports = Ajustes
