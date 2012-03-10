
port =  process.env.PORT || 9294

express = require('express')
app = express.createServer()
app.use(express.logger())
app.use(express.bodyParser())
app.use express.cookieParser()
app.use express.session secret: 'saimiri_australianus'

if process.env.NODE_ENV != "production"
  Hem = require("hem")
  hem = new Hem()
  app.get(hem.options.cssPath, hem.cssPackage().createServer())
  app.get(hem.options.jsPath, hem.hemPackage().createServer())

app.set 'views' , './views'
app.set 'view engine'  , 'jade'

app.use(express.static("./public"))

app.get '/' , (req, res) ->
 res.render "index"

app.get '/app/:app',(req,res)->
  res.render "app" , {app: req.params.app}

app.get '/test_set', (req, res) ->
  req.session.name = "testing"
  res.end("ok")

app.get '/test', (req, res) ->
  res.end(req.session.name)
  
    
app.listen(port)
console.log "Listening on port " + port

