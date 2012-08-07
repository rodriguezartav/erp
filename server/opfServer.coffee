port =  process.env.PORT || 9294

express = require('express')
OpfDevUtil = require("./opfDevUtil")
ParseController = require('./controllers/parseController')

Opf =require "opf"

##Setup Server
app = express.createServer()
app.use(express.logger())
app.use(express.bodyParser())
app.use express.cookieParser()

app.set 'views' , './views'
app.set 'view engine'  , 'jade'

new ParseController(app)    

OpfDevUtil.setupCompilers(app) if process.env.NODE_ENV != "production"
app.use(express.static("./public"))

##Setup Routes
app.get '/' , (req, res) ->
  res.render "app" , {useManifest: false, app: "" , pusherKey: process.env.PUSHER_KEY, parseKeys: req.parseController.keys() }

app.get '/test' , (req, res) -> 
  res.render "app" , {layout: "test",  app: "" , pusherKey: process.env.PUSHER_KEY, parseKeys: req.parseController.keys() }

app.get '/remote' , (req, res) ->
  res.render "app" , {useManifest: true,  app: "" , pusherKey: process.env.PUSHER_KEY, parseKeys: req.parseController.keys() }

app.all "/parse/users/?*" , (req,res) ->
  req.parseController.handleProxy(req,res)

app.listen(port)
console.log "Listening on port " + port