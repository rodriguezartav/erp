require('lib/setup')
Spine = require('spine')
User = require("models/user")
Lightbox = require("controllers/lightbox")
Recibos = require("apps/recibos")
Compras = require("apps/compras")

class App extends Spine.Controller

  constructor: ->
    super
    Spine.server = if @test then "http://127.0.0.1:9393" else "http://rodco-api2.heroku.com"
    @setup_plugins()
    User.retrieve()
    
    @application = null
    
    switch @app
      when "depositos" 
        @application = Recibos
      when "compras" 
        @application = Compras

  
    
    @application.login_complete = =>
      User.unbind "login_complete" , @login_complete
      @prepend new @application
      
    @append new Lightbox

    if @email
      User.current.session = { instance_url: @instance_url , token: @token }
      User.current.email = @email
      User.current.last_login = new Date()
      User.current.is_visualforce = true
      User.current.save()
      @application.login_complete()
    else
      Spine.trigger("show_lightbox","login")
      User.bind "login_complete" , @application.login_complete

  setup_plugins: =>
    $('.dropdown-toggle').dropdown()
    $('a.tipable').tooltip()
    $('a.popable').popover()
    $('#subnav').scrollspy(offset: -100)
    $(".auto-alert").alert()

module.exports = App
    