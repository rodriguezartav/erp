require('lib/setup')
Spine = require('spine')

class Estados extends Spine.Controller
  className: "estados"


  constructor: ->
    super
    @html require("views/main/estados/layout")
    

module.exports = Estados
