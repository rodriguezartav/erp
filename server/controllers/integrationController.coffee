restler = require('restler');
SalesforceLogin = require("../libs/salesforceLogin")
SalesforceApi = require("../libs/salesforceApi")
SalesforceModel = require("../../app/lib/salesforceModel")
Proveedor = require("../../app/models/proveedor")

#async = require "async"

class IntegrationController

  constructor: (@app) ->
    @app.use @middleware()

  middleware: =>
    return (req , res , next)  =>
      console.log "integration pass"
      req.integrationController = @
      return @generarCXP(req,res) if(req.url?.indexOf("/integration/generarCXP")     == 0)
      next()

  generarCXP: (req, res) =>
    return req.body

 
module.exports = IntegrationController