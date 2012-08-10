SalesforceLogin = require("../libs/salesforceLogin")
SalesforceApi = require("../libs/salesforceApi")
Salesforce = require("../../app/lib/salesforce")
Salesforce = require("../../app/lib/format")
User = require("../../app/models/user")

#async = require "async"

class SalesforceController

  constructor: (@app) ->
    @app.use @middleware()
    @api = SalesforceApi
    #@doUpdate()

  doUpdate: ->
    sf = new SalesforceLogin (success,token) =>
      @token = token
      @updateUsers()
      #async.parallel [@updateClientes , @updateDocumentos] , @onUpdateComplete

  onUpdateComplete: (error,results) =>
    #TODO HANDLE ERROR

  updateUsers: (cb) =>
    SalesforceApi.query @token , soql: "select id , Name , SmallPhotoUrl, Perfil__c , FirstName from User where IsActive = true" , (response) ->
      User.refresh User.parseSalesforceJSON JSON.stringify response.records
    , @onError

  onError: (error) ->
    console.log error

  middleware: =>
    return (req , res , next)  =>
      req.sfController = @
      next()

module.exports = SalesforceController