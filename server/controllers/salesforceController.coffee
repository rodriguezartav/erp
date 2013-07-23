restler = require('restler');
SalesforceLogin = require("../libs/salesforceLogin")
SalesforceApi = require("../libs/salesforceApi")
SalesforceModel = require("../../app/lib/salesforceModel")
User = require("../../app/models/user")
Mixpanel = require('mixpanel');
#async = require "async"

class SalesforceController

  constructor: (@app) ->
    @consumerKey= process.env.FORCE_DOT_COM_CLIENT_ID
    @consumerSecret= process.env.FORCE_DOT_COM_CLIENT_SECRET
    @loginServer = process.env.FORCE_DOT_COM_HOSTNAME
    @baseUrl= process.env.BASE_URL
    @redirectUrl = "#{@baseUrl}/sessions/salesforce/callback"

    @mixpanel = Mixpanel.init('e980478d760bd1bd06b2af38233baadc');
    

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

  updateUsers: (cb) =>
    SalesforceApi.query @serverToken , soql: "select id , Name , SmallPhotoUrl, Perfil__c , FirstName from User where IsActive = true" , (response) ->
      User.refresh response
    , @onError

  updateProveedores: (cb) =>
    SalesforceApi.query @serverToken , soql: "select id , Name , Codigo__c, Plazo__c  from Proveedor__c" , (response) ->
      Proveedor.refresh response
    , @onError
  
  onError: (error) ->
    #req.parseController.logAudit "Error" , "Server" , "Server" , error

  parseToken: (req,res) =>
    return req.session.salesforceToken if req.session.salesforceToken
    res.status = 500
    return false
    
  rest: (req,res) =>
    token = @parseToken(req,res)

    if !token
      res.statusCode = 503
      return res.send "Error de login, favor volver a cargar"

    data = 
      restRoute: req.param("restRoute")
      restMethod:   req.param("restMethod")
      restData:     req.param("restData")

    @mixpanel.track "SF API CALL" , { type: "REST" , path: data.restRoute , method: data.restMethod , distinct_id: req.session.salesforceToken.user.id }
    @mixpanel.people.track_charge(req.session.salesforceToken.user.Name , 1);
    

    #req.parseController.logAudit "Audit" , req.session.salesforceToken.user.id , req.session.salesforceToken.user.Name , req.body
    SalesforceApi.rest token , data  , (response) ->
      res.send response
    , (error) =>
      #req.parseController.logAudit "Error" , req.session.salesforceToken.user.id , req.session.salesforceToken.user.Name , error
      res.statusCode = 500
      res.send error
    
    
  handleProxy: (req,res) =>
    method = req.route.method
    path = req.route.path
    
    @mixpanel.people.track_charge(req.session.salesforceToken.user.Name , 1);
    
    if method == "GET" or method == "get"
      @handleGet(req,res)
      @mixpanel.track "SF API CALL" , { type: "QUERY" , query: req.query['soql'] , method: method , path: path  ,  distinct_id: req.session.salesforceToken.user.id }
      
    else  
      @mixpanel.track "SF API CALL" , { type: "API" , method: method , path: path  ,  distinct_id: req.session.salesforceToken.user.id }

      if method == "POST" or method == "post"
        @handlePost(req,res)
      
      if method == "PUT" or method == "put"
        @handlePut(req,res)

  handlePut: (req,res) =>
    token = @parseToken(req,res)
    if !token
      res.statusCode = 503
      return res.send "Error de login, favor volver a cargar"

    SalesforceApi.update token , req.body , (response) ->
      res.statusCode >= 200
      res.send response
    , (error) =>
      #req.parseController.logAudit "Error" , req.session.salesforceToken.user.id , req.session.salesforceToken.user.Name , error
      res.statusCode = 500
      res.send  error

  handlePost: (req,res) =>
    token = @parseToken(req,res)
    if !token
      res.statusCode = 503
      return res.send "Error de login, favor volver a cargar"
          
    SalesforceApi.create token , req.body , (response) ->
      res.statusCode >= 201
      res.send response
    , (error) =>
      #req.parseController.logAudit "Error" , req.session.salesforceToken.user.id , req.session.salesforceToken.user.Name , error
      res.statusCode = 500
      res.send  error

  handleGet: (req,res) =>
    token = @parseToken(req,res)
    if !token
      res.statusCode = 503
      return res.send "Error de login, favor volver a cargar" 
    
    if req.query['soql']
      @handleQuery(req,res,token)
    else
      res.statusCode = 500
      res.send  "NOT YET IMPLEMENTED"



  handleQuery: (req,res, token) =>
    res.records = []
    @doQuery(req,res,token)

  doQuery: (req,res,token,nextRecordsUrl ) =>
    if !nextRecordsUrl
      SalesforceApi.query token , soql: req.query['soql']  ,  (response) =>
        @doQueryCallback(req,res,token,response)
      , (error) =>
        res.statusCode = 500
        return res.send error

    else
      SalesforceApi.queryMore token , nextRecordsUrl: nextRecordsUrl  ,  (response) =>
        @doQueryCallback(req,res,token,response)
      , (error) =>
        res.statusCode = 500
        return res.send error

  doQueryCallback: (req,res,token,response) =>
    objResponse = JSON.parse response
    res.records = res.records.concat(objResponse.records)
    if objResponse.done
      res.send JSON.stringify records: res.records
    else
      @doQuery(req,res,token,objResponse.nextRecordsUrl)

  startAuth: (req, res) =>
    url = "#{@loginServer}/services/oauth2/authorize?response_type=code&client_id=#{@consumerKey}&redirect_uri=#{@redirectUrl}&display=touch"
    res.redirect(url);

  finishAuth: (req,res) =>
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
      
      @mixpanel.people.set(data.user.id , {
          $first_name: data.user.Name,
          $last_name: "",
          $created: (new Date()).toISOString(),
          Perfil: data.user.Perfil
      });
      
      
      res.redirect("/");

    post.on "error" , (error) ->
      #req.parseController.logAudit "Error" , "" , "Server - SF Controller" , error


module.exports = SalesforceController