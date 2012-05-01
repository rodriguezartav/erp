
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

#will change for customers
app.get '/' , (req, res) ->
  
  
  res.end()

#internal use
app.get '/erp' , (req, res) ->
  res.render "app" , { app: ""}
  
#update URL
# we wont use sockets for now
app.get "/update/"

app.listen(port)
console.log "Listening on port " + port

