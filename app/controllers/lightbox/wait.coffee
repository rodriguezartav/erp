Spine   = require('spine')
User = require('models/user')
Error = require('models/error')
$       = Spine.$

class Wait extends Spine.Controller
  className: 'showWarning modal'



  @type = "showWait"

  constructor: ->
    super
    @html require('views/controllers/lightbox/wait')()

  accept: =>
    Spine.trigger "hide_lightbox"
    @callback?.apply @, [true]
    
    
module.exports = Wait