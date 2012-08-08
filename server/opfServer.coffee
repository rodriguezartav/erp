port =  process.env.PORT || 9294

express = require('express')
OpfDevUtil = require("./opfDevUtil")
ParseController = require('./controllers/parseController')
PusherController = require('./controllers/pusherController')
#TwilioController = require('./controllers/twilioController')
Cors = require ("./libs/cors")


Opf =require "opf"

##Setup Server
app = express.createServer()
app.use(express.logger())
app.use(express.bodyParser())
app.use express.cookieParser()

app.set 'views' , './views'
app.set 'view engine'  , 'jade'

cors = new Cors(app)
new ParseController(app)
new PusherController(app)
#new TwilioController(app)

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

app.post "/pusherAuth" , (req,res) ->
  channel_name = req.body.channel_name
  socket_id = req.body.socket_id
  res.send req.pusherController.auth(socket_id,channel_name)

app.listen(port)
console.log "Listening on port " + port