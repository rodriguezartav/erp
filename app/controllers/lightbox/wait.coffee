Spine   = require('spine')
User = require('models/user')
Error = require('models/error')
$       = Spine.$

class Wait extends Spine.Controller
  className: 'showWarning modal'

  @type = "showWait"

  elements:
    ".bar"  : "bar"
  
  constructor: ->
    super
    @html require('views/controllers/lightbox/wait')()
    @max = 0
    Spine.bind "bulkProgress" , (values) =>
      @max = values[1] if @max == 0
      p = 100 - ( values[0] * 100 / @max )
      @bar.css( "width" , "#{p}%" )

  accept: =>
    Spine.trigger "hide_lightbox"
    @callback?.apply @, [true]
    
    
module.exports = Wait