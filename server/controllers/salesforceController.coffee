restler = require('restler');
SalesforceLogin = require("../libs/salesforceLogin")
SalesforceApi = require("../libs/salesforceApi")
SalesforceModel = require("../../app/lib/salesforceModel")
User = require("../../app/models/user")

#async = require "async"

class SalesforceController

  constructor: (@app) ->
    @consumerKey= process.env.FORCE_DOT_COM_CLIENT_ID
    @consumerSecret= process.env.FORCE_DOT_COM_CLIENT_SECRET
    @loginServer = process.env.FORCE_DOT_COM_HOSTNAME
    @baseUrl= process.env.BASE_URL
    @redirectUrl = "#{@baseUrl}/sessions/salesforce/callback"

    @app.use @middleware()
    @api = SalesforceApi
    @doUpdate()

  middleware: =>
    return (req , res , next)  =>
      req.salesforceController = @
      return @startAuth(req,res) if(req.url?.indexOf("/sessions/salesforce/login")     == 0)
      return @finishAuth(req,res) if(req.url?.indexOf("/sessions/salesforce/callback")  == 0)
      next()

  doUpdate: ->
    sf = new SalesforceLogin (success,response) =>
      if success
        @token = response
        @updateUsers()
      else
        console.log response
      #async.parallel [@updateClientes , @updateDocumentos] , @onUpdateComplete

  onUpdateComplete: (error,results) =>
    #TODO HANDLE ERROR

  updateUsers: (cb) =>
    SalesforceApi.query @token , soql: "select id , Name , SmallPhotoUrl, Perfil__c , FirstName from User where IsActive = true" , (response) ->
      User.refresh response
    , @onError

  onError: (error) ->
    console.log error

  parseToken: (req) ->
    return req.session.salesforceToken if req.session.salesforceToken
    return @token

  handleProxy: (req,res) =>
    console.log "SALESFORCE PROXY"
    method = req.route.method
    path = req.route.path
    token = @parseToken(req)
    console.log req.query
    SalesforceApi.query token , soql: req.query['soql']  , (response) ->
      res.send response
    , (error) ->
      console.log error
      res.statusCode = 500
      res.send  error

  keys: (req) ->
    req.session.salesforceToken

  startAuth: (req, res) =>
    url = "#{@loginServer}/services/oauth2/authorize?response_type=code&client_id=#{@consumerKey}&redirect_uri=http://localhost:9294/sessions/salesforce/callback&display=touch"
    console.log('redirecting: '+url);
    res.redirect(url);

  finishAuth: (req,res) =>
    console.log('code: '+req.query.code);
    post = restler.post "#{@loginServer}/services/oauth2/token" ,
      data:
        code: req.query.code
        grant_type: 'authorization_code'
        client_id: @consumerKey
        redirect_uri: @redirectUrl
        client_secret: @consumerSecret

    post.on 'complete' , (data, response) =>
      lastS = data.id.lastIndexOf "/"
      userId = data.id.substring(lastS + 1) 
      data.user = User.exists userId
      req.session.salesforceToken =  data

      res.redirect("/test");

    post.on "error" , ->
      console.log arguments


module.exports = SalesforceController