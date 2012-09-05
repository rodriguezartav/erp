restler = require('restler');
SalesforceLogin = require("../libs/salesforceLogin")
SalesforceApi = require("../libs/salesforceApi")
SalesforceModel = require("../../app/lib/salesforceModel")
User = require("../../app/models/user")
Proveedor = require("../../app/models/proveedor")

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
      console.log "salesforce pass"
      req.salesforceController = @
      return @startAuth(req,res) if(req.url?.indexOf("/sessions/salesforce/login")     == 0)
      return @finishAuth(req,res) if(req.url?.indexOf("/sessions/salesforce/callback")  == 0)
      next()

  keys: (req) ->
    req.session.salesforceToken

  doUpdate: ->
    sf = new SalesforceLogin (success,response) =>
      if success
        @serverToken = response
        @updateUsers()
        @updateProveedores()

  updateUsers: (cb) =>
    SalesforceApi.query @serverToken , soql: "select id , Name , SmallPhotoUrl, Perfil__c , FirstName from User where IsActive = true" , (response) ->
      User.refresh response
    , @onError

  updateProveedores: (cb) =>
    SalesforceApi.query @serverToken , soql: "select id , Name , Codigo__c, Plazo__c  from Proveedor__c" , (response) ->
      Proveedor.refresh response
    , @onError
  
  onError: (error) ->
    console.log error

  parseToken: (req,res) =>
    return req.session.salesforceToken if req.session.salesforceToken
    res.status = 500
    return false
    
  rest: (req,res) =>
    token = @parseToken(req,res)
    return res.send "Error de login, favor volver a cargar" if !token
    #req.body = req.query if req.query
    SalesforceApi.rest token , req.body  , (response) ->
      res.send response
    , (error) ->
      console.log error
      res.statusCode = 500
      res.send error
    
    
  handleProxy: (req,res) =>
    method = req.route.method
    path = req.route.path
    if method == "GET" or method == "get"
      @handleGet(req,res)
    if method == "POST" or method == "post"
      @handlePost(req,res)
    if method == "PUT" or method == "put"
      @handlePut(req,res)
    

  handlePut: (req,res) =>
    token = @parseToken(req,res)
    return res.send "Error de login, favor volver a cargar" if !token
    SalesforceApi.update token , req.body , (response) ->
      res.statusCode >= 200
      res.send response
    , (error) ->
      console.log error
      res.statusCode = 500
      res.send  error

  handlePost: (req,res) =>
    token = @parseToken(req,res)
    return res.send "Error de login, favor volver a cargar" if !token
    
    SalesforceApi.create token , req.body , (response) ->
      res.statusCode >= 201
      res.send response
    , (error) ->
      console.log error
      res.statusCode = 500
      res.send  error

  handleGet: (req,res) =>
    token = @parseToken(req,res)
    if !token
      res.statusCode = 500
      return res.send "Error de login, favor volver a cargar" 
    
    if req.query['soql']
      @handleQuery(req,res,token)
    else
      res.statusCode = 500
      res.send  "NOT YET IMPLEMENTED"

  handleQuery: (req,res, token) =>
    SalesforceApi.query token , soql: req.query['soql']  , (response) ->
      res.send response
    , (error) ->
      console.log error
      res.statusCode = 500
      res.send  error

  startAuth: (req, res) =>
    url = "#{@loginServer}/services/oauth2/authorize?response_type=code&client_id=#{@consumerKey}&redirect_uri=#{@redirectUrl}&display=touch"
    console.log('redirecting: '+url);
    res.redirect(url);

  finishAuth: (req,res) =>
    console.log( 'code: ' + req.query.code );
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
      req.session.salesforceToken = data
      res.redirect("/");

    post.on "error" , ->
      console.log arguments


module.exports = SalesforceController