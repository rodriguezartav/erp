#Cliente = require("../app/models/cliente")
User = require("../app/models/user")

class Routes

  constructor: (@app) ->    
    @setupRoutes()

  setupRoutes: ->
    
    @app.get '/' , (req, res) =>
      #res.redirect "/dev" if process.env.NODE_ENV == 'development'
      res.render "app" , { jsvars: @getJsVars(req) }

    @app.get '/dev' , (req, res) =>
      res.render "app" , {layout: "dev" , jsvars: @getJsVars(req) }

    @app.get '/checkStatus' , (req, res) =>
      if req.session.salesforceToken then return res.send
        id: req.session.salesforceToken.id
        instance_url: req.session.salesforceToken.instance_url
        issued_at: req.session.salesforceToken.issued_at
      res.send 500

    @app.all "/parse/users/?*" , (req,res) ->
      #req.parseController.handleProxy(req,res)

    @app.all "/salesforce/sobjects/?*" , (req,res) ->
      req.salesforceController.handleProxy(req,res)

    @app.all "/salesforce/rest/?*" , (req,res) ->
      req.salesforceController.rest(req,res)

    @app.post "/pusherAuth" , (req,res) ->
      channel_name = req.body.channel_name
      socket_id = req.body.socket_id
      user_details = JSON.parse req.body.user_details
      res.send req.pusherController.auth(socket_id,channel_name , user_details )

    @app.get "/logout" , (req,res) =>
      req.session.destroy( =>  )
      res.redirect "/"

    @app.get "/integration" , (req,res) =>
      token = req.salesforceController.serverToken;
      req.salesforceController.api.rest token , { restRoute: 'Integration' , restMethod: "GET" } , (response) => 
        console.log response
        res.send response
      , (response , error) =>
        console.log error
        res.send response

      
    @app.get "/AQuienLlamo" , (req,res) =>
      token = req.salesforceController.serverToken;
      req.salesforceController.api.rest token , { restRoute: 'AQuienLlamo' , restMethod: "GET" } , (response) => 
        console.log arguments
        res.send response
      , (response , error) =>
        console.log error
        res.send response
      
    @app.get "/rest" , (req,res) =>
      restRoute = req.query['restRoute']
      token = req.salesforceController.serverToken;
      req.salesforceController.api.rest token , { restRoute: restRoute , restMethod: "GET" , restData: '{}' } , (response) => 
        console.log arguments
        res.send response
      , (response , error) =>
        console.log error
        res.send response

  getJsVars: (req) ->
    jsvars = 
      pusherKeys: req.pusherController.keys()
      #parseKeys: req.parseController.keys()
      statApi: "7fe222080e1ae26d9f89ba1ba8f320b2"
      mixPanel: process.env["MIXPANEL_API"]
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
