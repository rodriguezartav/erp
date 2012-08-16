#Cliente = require("../app/models/cliente")


class Routes

  constructor: (@app) ->    
    @setupRoutes()

  setupRoutes: ->
    @app.get '/' , (req, res) ->
      res.render "app" , {useManifest: false, app: ""  , pusherKeys: req.pusherController.keys(), parseKeys: req.parseController.keys() }

    @app.get '/test' , (req, res) -> 
      res.render "app" , {layout: "test",  app: "" , pusherKeys: req.pusherController.keys() , parseKeys: req.parseController.keys() }

    @app.get '/remote' , (req, res) ->
      res.render "app" , {useManifest: true,  app: ""  , pusherKeys: req.pusherController.keys() , parseKeys: req.parseController.keys() }

    @app.all "/parse/users/?*" , (req,res) ->
      req.parseController.handleProxy(req,res)

    @app.post "/pusherAuth" , (req,res) ->
      channel_name = req.body.channel_name
      socket_id = req.body.socket_id
      user_details = JSON.parse req.body.user_details
      res.send req.pusherController.auth( socket_id , channel_name , user_details )

  @varsToString: (vars) ->
    str= ""
    for key, value of vars
      if value
        json = JSON.stringify(value)
        str += ", #{key}: #{json}"
    str
    
module.exports = Routes
