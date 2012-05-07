Spine   = require('spine')
User = require('models/user')
Error = require('models/error')
$       = Spine.$

class ShowError extends Spine.Controller
  className: 'showWarning modal'


  events:
    "click .accept" : "accept"

  @type = "showError"

  constructor: ->
    super
    @html require('views/lightbox/showError')(@data)

  accept: =>
    Spine.trigger "hide_lightbox"
    @callback?.apply @, [true]
    
    
module.exports = ShowError