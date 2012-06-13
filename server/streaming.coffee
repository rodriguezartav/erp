Faye = require 'faye'
Pusher = require 'node-pusher'

class SalesforceStreaming

  constructor: (@app) ->
    @pusher = new Pusher
      appId: process.env.PUSHER_APP_ID,
      key: process.env.PUSHER_KEY,
      secret: process.env.PUSHER_SECRET

  whenLoggedIn: (oauth) =>
    @pusher.trigger "salesforce_connection_information" , 'connect' , {"message": "Connection Established with Server"}
    
    url = oauth.instance_url + '/cometd/25.0/'
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
    @subscribe("PrintableFacturas")

  subscribe: (channel = "AllProductos") =>
    subscription = @fayeClient.subscribe "/topic/#{channel}", (message) =>  
      console.log message
      @pusher.trigger "salesforce_data_push" , channel , message

    subscription.errback (error) =>
      console.log error
      @pusher.trigger "salesforce_connection_information" , 'error', {"message": "There was an error in the Server- Salesforce Connection " , "error": "#{error}"}
    
    subscription.callback ->
      console.log "Active"

  attempUnSubscription: =>
    @fayeClient?.unsubscribe("/topic/AllPedidos")
    @fayeClient?.unsubscribe("/topic/PrintableFacturas")

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
    
    
module.exports = SalesforceStreaming