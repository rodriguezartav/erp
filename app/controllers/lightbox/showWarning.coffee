Spine   = require('spine')
User = require('models/user')
Error = require('models/error')
$       = Spine.$

class ShowWarning extends Spine.Controller
  className: 'showWarning modal'


  events:
    "click .accept" : "accept"

  @type = "showWarning"

  constructor: ->
    super
    @error = @data
    @html require('views/lightbox/showWarning')(@error)

  accept: =>
    Spine.trigger "hide_lightbox"
    
module.exports = ShowWarning