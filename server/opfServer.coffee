port =  process.env.PORT || 9294

express = require('express')
Opf = require "opf"


ParseController  = require('./controllers/parseController')
PusherController = require('./controllers/pusherController')
SalesforceController = require('./controllers/salesforceController')

Cors             = require ("./libs/cors")
OpfDevUtil       = require("./libs/opfDevUtil")
Routes           = require("./routes")

##Setup Server
app = express.createServer()
app.use(express.logger())
app.use(express.bodyParser())
app.use express.cookieParser({httpOnly: false})
app.use express.session({secret:"saimiri aesterdius"})

app.set 'views' , './views'
app.set 'view engine'  , 'jade'

new Cors(app)
new ParseController(app)
new PusherController(app)
new SalesforceController(app)

OpfDevUtil.setupCompilers(app) if process.env.NODE_ENV != "production"
app.use(express.static("./public"))

new Routes(app)

app.listen(port)
console.log "Listening on port " + port