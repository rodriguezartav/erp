Kaiseki = require("kaiseki")

class ParseController

  constructor: (@app) ->
    @appId= process.env.PARSE_APP_ID
    @restKey= process.env.PARSE_REST_API_KEY
    @masterKey = process.env.PARSE_MASTER_API_KEY
    @kaiseki = new Kaiseki(process.env.PARSE_APP_ID, process.env.PARSE_REST_API_KEY);
    @kaiseki.masterKey = process.env.PARSE_MASTER_API_KEY;

    @app.parseController = @
    @app.use @middleware()
    
    

    
  keys: =>
    apiKeys=
      restKey: @appId
      appId: @restKey
      masterKey: @masterKey 
    JSON.stringify apiKeys
  
  middleware: =>
    return (req , res , next)  =>
      console.log "parse pass"
      req.parseController = @
      next()

  
  handleProxy: (req,res) =>
    console.log "HANDLGIN PROXU"
    
    method = req.route.method
    if method == "get"
      req.parseController.kaiseki.getUsers req.query , (err, internalResponse, body) =>
        res.send body

    else if method == "delete"
      id = req.params[0]    
      req.parseController.kaiseki.deleteUser id, (err,internalResponse) =>
        res.send internalResponse.statusCode

    else if method == "post"
      req.parseController.kaiseki.createUser req.body, (err,internalResponse,body) =>
        res.send body

    else if method == "put"
      id = req.params[0]    
      req.parseController.kaiseki.updateUser id, req.body, (err,internalResponse,body) =>
        res.send body
  
module.exports = ParseController