
port =  process.env.PORT || 9294

express = require('express')
forceOAuth = require('./force_dot_com_oauth');
forceQuery = require('./force_dot_com_query');
faye = require 'faye'


##Setup Server
app = express.createServer()
app.use(express.logger())
app.use(express.bodyParser())
app.use express.cookieParser()
#app.use express.session secret: 'saimiri_australianus'

if process.env.NODE_ENV != "production"
  Hem = require("hem")
  hem = new Hem()
  app.get(hem.options.cssPath, hem.cssPackage().createServer())
  app.get(hem.options.jsPath, hem.hemPackage().createServer())
  
app.set 'views' , './views'
app.set 'view engine'  , 'jade'

app.subscribe= (client,channel) =>
  subscription = client.subscribe "/topic/#{channel}", (message) =>
    console.log message

  subscription.errback (error) ->
    console.log error.message
  
app.onLogin= =>
  url = forceOAuth.getOAuthResponse().instance_url + '/cometd/24.0/'
  auth = forceOAuth.getOAuthResponse().access_token
  client = new faye.Client(url);
  client.setHeader('Authorization', "OAuth #{auth}");
  app.subscribe(client,'Cliente__c')
  app.subscribe(client,'Producto__c')
  app.subscribe(client,'Pedido__c')
  
app.use(express.static("./public"))
forceOAuth.login app.onLogin

  
##Setup Routes

app.get '/' , (req, res) ->
  res.render "app" , { app: ""}
  
app.get '/app/:app',(req,res)->
  res.render "app" , {app: req.params.app}

app.get '/print/:id' , (req,res) ->
  forceQuery.queryDoc(forceOAuth,"select name from client__c limit 1")
  return "ok"

app.listen(port)
console.log "Listening on port " + port

