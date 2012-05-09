
port =  process.env.PORT || 9294

express = require('express')
OPF = require("opf")
SalesforceStreaming = require ("./salesforceStreaming")
OPF.debug= true

##Setup Server
app = express.createServer()
app.use(express.logger())
app.use(express.bodyParser())
app.use express.cookieParser()

if process.env.NODE_ENV != "production"
  Hem = require("hem")
  hem = new Hem()
  app.get(hem.options.jsPath, hem.hemPackage().createServer())
  
app.set 'views' , './views'
app.set 'view engine'  , 'jade'
app.use(express.static("./public"))

webLogin = OPF.Salesforce.webLogin()
sfStreaming = new SalesforceStreaming(app)

OPF.bind "web_login_complete" , =>
  sfStreaming.whenLoggedIn(webLogin.oauthToken)

##Setup Routes

app.get '/' , (req, res) ->
  console.log process.env.PUSHER_KEY
  res.render "app" , {useManifest: false, app: "" , pusherKey: process.env.PUSHER_KEY }
  
app.get '/remote' , (req, res) ->
  console.log process.env.PUSHER_KEY
  res.render "app" , {useManifest: true,  app: "" , pusherKey: process.env.PUSHER_KEY }


app.listen(port)
console.log "Listening on port " + port

