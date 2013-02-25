Spine   = require('spine')
User = require('models/user')
Error = require('models/error')
$       = Spine.$

class ShowInfo extends Spine.Controller
  className: 'ShowInfo modal'


  events:
    "click .accept" : "accept"

  @type = "showInfo"

  constructor: ->
    super
    @html require('views/controllers/lightbox/showInfo')(@data)

  accept: =>
    Spine.trigger "hide_lightbox"
    @callback?.apply @, [true]
    
    
module.exports = ShowInfo