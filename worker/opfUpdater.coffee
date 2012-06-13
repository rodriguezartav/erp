Spine = require("spine")
OPF = require("opf")

rest = require("restler")

Faye = require 'faye'
Pusher = require('node-pusher');
OPF.debug= true

class opfUpdater

  constructor: ->
    @webLogin = OPF.Salesforce.webLogin()
    @sfStreaming = new SalesforceStreaming()

    OPF.bind "web_login_complete" , =>
          
      @sfStreaming.whenLoggedIn(@webLogin.oauthToken)
      #@salesforceUpdater = new SalesforceUpdater(@webLogin.oauthToken)

    process.on 'SIGINT', =>
      console.log( "\ngracefully shutting down from  SIGINT (Crtl-C)" )
      @sfStreaming?.attempUnSubscription()
      @sfStreaming?.disconnect()
      process.exit( )

class SalesforceStreaming

  constructor: (@app) ->
    @pusher = new Pusher
      appId: process.env.PUSHER_APP_ID,
      key: process.env.PUSHER_KEY,
      secret: process.env.PUSHER_SECRET

  whenLoggedIn: (oauth) =>
    @pusher.trigger "salesforce_connection_information" , 'connect' , {"message": "Connection Established with Server"}

    url = oauth.instance_url + '/cometd/24.0/'
    auth = oauth.access_token

    @fayeClient = new Faye.Client(url , {retry: 5, timeout: 2 });
    @fayeClient.handshake = @handshake
    @fayeClient.subscribeToChannels = @subscribeToChannels

    Logger = {
      incoming: (message, callback) =>
        console.log('incoming', message);
        callback(message);
      ,
      outgoing: (message, callback) ->
        console.log('outgoing', message);
        callback(message);
    }

    @fayeClient.addExtension(Logger)
    @fayeClient.setHeader('Authorization', "OAuth #{auth}");
    @fayeClient.handshake()

  subscribeToChannels: =>
    @fayeClient.connect()
    setTimeout @attempSubscription , 10000

  attempSubscription: =>
    @subscribe('AllPedidos')
    @subscribe("AllDocumentos")

  subscribe: (channel = "AllProductos") =>
    subscription = @fayeClient.subscribe "/topic/#{channel}", (message) =>  
      @pusher.trigger "salesforce_data_push" , channel , message

    subscription.errback (error) =>
      console.log error
      @pusher.trigger "salesforce_connection_information" , 'error', {"message": "There was an error in the Server- Salesforce Connection " , "error": "#{error}"}

    subscription.callback ->
      console.log "Active"

  attempUnSubscription: =>
    @fayeClient?.unsubscribe("/topic/AllPedidos")
    @fayeClient?.unsubscribe("/topic/AllDocumentos")

  disconnect: =>
    @fayeClient?.disconnect()

  handshake: (callback, context) ->
    return  if @_advice.reconnect is @NONE
    return  if @_state isnt @UNCONNECTED
    @_state = @CONNECTING
    self = this
    @info "Initiating handshake with ?", @endpoint
    @_send
      channel: Faye.Channel.HANDSHAKE
      version: Faye.BAYEUX_VERSION
      supportedConnectionTypes: [ @_transport.connectionType ]
    , ((response) ->
      if response.successful
        @_state = @CONNECTED
        @_clientId = response.clientId
        connectionTypes = Faye.filter(response.supportedConnectionTypes, (connType) ->
          Faye.indexOf(@_disabled, connType) < 0
        , this)
        @_selectTransport connectionTypes
        @info "Handshake successful: ?", @_clientId
        #@subscribe @_channels.getKeys(), true

        @subscribeToChannels()
        callback.call context  if callback
      else
        @info "Handshake unsuccessful"
        Faye.ENV.setTimeout (->
          self.handshake callback, context
        ), @_advice.interval
        @_state = @UNCONNECTED
    ), this

class SalesforceUpdater

  constructor: (auth) ->
    date = new Date(Date.parse("1970-1-1"));
    RestApi.query auth , soql: "select id,name,InventarioActual__c from producto__c where lastModifiedDate > #{date.to_salesforce_date()}" , @onProductoQuery

  onProductoQuery: (results) ->
    productos = results.records
    for producto in productos
      producto.attributes = null
    console.log productos


class RestApi

  @apiVersion = "24.0"

  @request: (options) ->
    restUrl = (if options.path.substr(0, 6) is "https:" then options.path else options.oauth.instance_url + "/services/data" + options.path)
    console.log "SALESFORCE:RESTAPI:REQUEST ::>  Method: " + options.method || "GET"
    console.log "SALESFORCE:RESTAPI:REQUEST ::>  Url: " + restUrl + ", data: " + options.data || options.path
    console.log "SALESFORCE:RESTAPI:REQUEST ::>  Data: " + options.data

    reqOptions =
      method: options.method
      data: options.data
      headers:
        Accept: "application/json"
        Authorization: "OAuth " + options.oauth.access_token
        "Content-Type": "application/json"

    req = rest.request restUrl, reqOptions

    req.on "complete", (data, response) =>
      if response.statusCode >= 200 and response.statusCode < 300
        #console.log "SALESFORCE:RESTAPI:COMPLETE: " + data
        if data.length is 0
          options.callback()
        else
          options.callback JSON.parse(data)
      else
       # console.log arguments
        options.error data

    req.on "error", (data, response) =>
      options.error arguments


      console.error "SALESFORCE:RESTAPI:ERROR: " + data
      if response.statusCode is 401
        console.log response
        #if options.retry or not options.refresh
         # console.log "Invalid session - we tried!"
          #options.error data, response
        #else
        #console.log "Invalid session - trying a refresh"
        #options.refresh (oauth) ->
          #options.oauth.access_token = oauth.access_token
          #options.retry = true
          #request options
      else
        options.error data, response


  @versions: (oauth,callback, error) ->
    options =
      oauth: oauth
      path: "/"
      callback: callback
      error: error

    RestApi.request options

  @resources: (oauth,callback, error) ->
    options =
      oauth: oauth
      path: "/v" + @apiVersion + "/"
      callback: callback
      error: error

    RestApi.request options

  @describeGlobal: (oauth,callback, error) ->
    options =
      oauth: oauth
      path: "/v" + @apiVersion + "/sobjects/"
      callback: callback
      error: error

    RestApi.request options

  @identity: (oauth,callback, error) ->
    options =
      oauth: oauth
      path: oauth.id
      callback: callback
      error: error

    RestApi.request options

  @metadata: (oauth,data, callback, error) ->
    options =
      oauth: oauth
      path: "/v" + @apiVersion + "/sobjects/" + data.objtype + "/"
      callback: callback
      error: error

    RestApi.request options

  @describe: (oauth,data, callback, error) ->
    options =
      oauth: oauth
      path: "/v" + @apiVersion + "/sobjects/" + data.objtype + "/describe/"
      callback: callback
      error: error

    RestApi.request options

  @create: (oauth,data, callback, error) ->
    options =
      oauth: oauth
      path: "/v" + @apiVersion + "/sobjects/" + data.objtype + "/"
      callback: callback
      error: error
      method: "POST"
      data: JSON.stringify(data.fields)

    RestApi.request options

  @retrieve: (oauth,data, callback, error) ->
    if typeof data.fields is "function"
      error = callback
      callback = data.fields
      data.fields = null
    options =
      oauth: oauth
      path: "/v" + @apiVersion + "/sobjects/" + data.objtype + "/" + data.id + (if data.fields then "?fields=" + data.fields else "")
      callback: callback
      error: error

    RestApi.request options

  @upsert: (oauth,data, callback, error) ->
    options =
      oauth: oauth
      path: "/v" + @apiVersion + "/sobjects/" + data.objtype + "/" + data.externalIdField + "/" + data.externalId
      callback: callback
      error: error
      method: "PATCH"
      data: JSON.stringify(data.fields)

    RestApi.request options

  @update: (oauth, data, callback, error) ->
    options =
      oauth: oauth
      path: "/v" + @apiVersion + "/sobjects/" + data.objtype + "/" + data.id
      callback: callback
      error: error
      method: "PATCH"
      data: JSON.stringify(data.fields)

    RestApi.request options

  @del: (oauth,data, callback, error) ->
    options =
      oauth: oauth
      path: "/v" + @apiVersion + "/sobjects/" + data.objtype + "/" + data.id
      callback: callback
      error: error
      method: "DELETE"

    RestApi.request options

  @search: (oauth,data, callback, error) ->
    options =
      oauth: oauth
      path: "/v" + @apiVersion + "/search/?q=" + escape(data.sosl)
      callback: callback
      error: error

    RestApi.request options

  @query: (oauth,data, callback, error) ->
    options =
      oauth: oauth
      path: "/v" + @apiVersion + "/query/?q=" + escape(data.soql)
      callback: callback
      error: error

    RestApi.request options

  @recordFeed: (oauth,data, callback, error) ->
    options =
      oauth: oauth
      path: "/v" + @apiVersion + "/chatter/feeds/record/" + data.id + "/feed-items"
      callback: callback
      error: error

    RestApi.request options

  @newsFeed: (oauth,data, callback, error) ->
    options =
      oauth: oauth
      path: "/v" + @apiVersion + "/chatter/feeds/news/" + data.id + "/feed-items"
      callback: callback
      error: error

    RestApi.request options

  @profileFeed : (oauth,data, callback, error) ->
    options =
      oauth: oauth
      path: "/v" + @apiVersion + "/chatter/feeds/user-profile/" + data.id + "/feed-items"
      callback: callback
      error: error

    RestApi.request options


module.exports = opfUpdater