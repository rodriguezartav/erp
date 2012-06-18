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
    @html require('views/controllers/lightbox/showWarning')(@data)
    

  accept: =>
    Spine.trigger "hide_lightbox"
    @callback?.apply @, [true]
    
    
module.exports = ShowWarning