port =  process.env.PORT || 9294

express = require('express')
OPF = require("opf")
OpfDevUtil = require("./opfDevUtil")
OPF.debug= true

##Setup Server
app = express.createServer()
app.use(express.logger())
app.use(express.bodyParser())
app.use express.cookieParser()

app.set 'views' , './views'
app.set 'view engine'  , 'jade'

OpfDevUtil.setupCompilers(app) if process.env.NODE_ENV != "production"
app.use(express.static("./public"))

app.get '/' , (req, res) ->
  res.render "app" , {useManifest: false, app: "" , pusherKey: process.env.PUSHER_KEY }
  
app.get '/remote' , (req, res) ->
  res.render "app" , {useManifest: true,  app: "" , pusherKey: process.env.PUSHER_KEY }

app.listen(port)
console.log "Listening on port " + port

