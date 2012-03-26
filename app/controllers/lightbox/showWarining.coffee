Spine   = require('spine')
User = require('models/user')
Error = require('models/error')
$       = Spine.$

class ShowWarning extends Spine.Controller
  className: 'showWarning modal'


  events:
    "click .save" : "save"
    "click .cancel" : "cancel"

  @type = "showWarning"

  constructor: ->
    super
    @error = @data
    @html require('views/lightbox/showWarning')(Error.all())

  acept: =>
    Error.destroyAll();
    Spine.trigger "hide-lightbox"
    
module.exports = ShowWarning