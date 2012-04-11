Spine   = require('spine')
Session = require('models/session')
$       = Spine.$

class Block extends Spine.Controller
  className: 'block modal'
  @type = "block"

  events:
    "click .ok" : "on_continue"
  
  constructor: ->
    super
  
 
  on_continue: =>
    if Spine.session.isExpired()
      Spine.trigger "show_lightbox" , "login" , @options , @loginComplete
      
      _kmq.push(['record', 'unblocked']);
      for model in Spine.nSync
        if model.autoReQuery
          model.query()

    Spine.trigger "hide_lightbox"


module.exports = Block