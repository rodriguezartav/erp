Spine   = require('spine')
Session = require('models/session')
$       = Spine.$
StatManager = require("managers/statManager")

class AuthLogin extends Spine.Controller
  @extend Spine.Controller.Modal
  
  className: 'login modal'


  events:
    "click .offline" : "onOffine"

  @type = "authLogin"

  constructor: ->
    super
    return @continue() if @data.salesforceKeys
    @render()

  continue: =>
    Spine.session = Session.record || Session.create()
    
    Spine.session.createFromAuth(@data.salesforceKeys)

    return @render() if Spine.session.isExpired()
    Spine.trigger "hide_lightbox"
    Spine.trigger "login_complete"
    @callback()

  render: ->
    @html require("views/controllers/lightbox/login/authLogin")

  onOffine: ->
    return @render() if !Session.record
    Spine.session = Session.record
    console.log Spine.session
    Spine.trigger "hide_lightbox"
    Spine.trigger "login_complete"
    @callback()
    

module.exports = AuthLogin