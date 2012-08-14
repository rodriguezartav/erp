#Cliente = require("../app/models/cliente")
User = require("../app/models/user")


class Routes

  constructor: (@app) ->    
    @setupRoutes()

  setupRoutes: ->
    
    
    @app.get '/' , (req, res) =>
      res.render "app" , { jsvars: @getJsVars(req) }

    @app.get '/test' , (req, res) => 
      console.log req.session.salesforceToken
      res.render "app" , {layout: "test", jsvars: @getJsVars(req)   }

    @app.get '/remote' , (req, res) =>
      res.render "app" , { jsVars: @getJsVars(req) }

    @app.all "/parse/users/?*" , (req,res) ->
      req.parseController.handleProxy(req,res)

    @app.all "/salesforce/sobjects/?*" , (req,res) ->
      req.salesforceController.handleProxy(req,res)

    @app.all "/salesforce/rest/?*" , (req,res) ->
      req.salesforceController.rest(req,res)

    @app.post "/pusherAuth" , (req,res) ->
      channel_name = req.body.channel_name
      socket_id = req.body.socket_id
      user_details = JSON.parse req.cookies.user_details
      res.send req.pusherController.auth(socket_id,channel_name , user_details )
    
  getJsVars: (req) ->
    jsvars = 
      salesforceKeys: req.salesforceController.keys(req)
      pusherKeys: req.pusherController.keys()
      parseKeys: req.parseController.keys()
      statApi: "7fe222080e1ae26d9f89ba1ba8f320b2"
      server: "http://rodco-api2.heroku.com"
      instance_url: "https://na7.salesforce.com"
      apiServer: "http://api2s.heroku.com"
      users: User.all()
      
    return Routes.varsToString jsvars
      
  @varsToString: (vars) ->
    str= ""
    for key, value of vars
      if value
        json = JSON.stringify(value)
        str += ", #{key}: #{json}"
    str
    
module.exports = Routes
