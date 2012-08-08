class Cors 

  constructor: (@app) ->
    @app.use @middleware()

  middleware: =>
    return (req , res , next)  =>
      console.log "CORS " + req.headers.origin
      origin =  @checkOrigin(req.headers.origin)
      res.header('Access-Control-Allow-Origin'  , origin);
      res.header('Access-Control-Allow-Methods' , 'GET,PUT,POST,DELETE');
      res.header("Access-Control-Allow-Headers" , "Accept,Content-Type,X-Requested-With,X-Parse-REST-API-Key,X-Parse-REST-API-Key");

      return res.send 200 if 'OPTIONS' == req.method
      next();
      
  checkOrigin: (origin) ->
    return "*" if !origin
    allowOrigin = origin if origin.indexOf("localhost") > -1 
    allowOrigin = origin if origin.indexOf("heroku") > -1 
    allowOrigin = origin if origin.indexOf("herokuapp") > -1
    allowOrigin = origin if origin.indexOf("rodcocr") > -1
    allowOrigin = origin if origin.indexOf("visual.force") > -1
    allowOrigin = origin if origin.indexOf("force.com") > -1
    allowOrigin = origin if origin.indexOf("salesforce.com") > -1
    allowOrigin

module.exports = Cors