OPF = require("opf")
SocketIO = require('socket.io')
faye = require 'faye'


class SalesforceStreaming

  constructor: (@app) ->
      
    @socketIO = SocketIO.listen(@app);

    @socketIO.configure =>
      @socketIO.set("transports", ["xhr-polling"]); 
      @socketIO.set("polling duration", 10);


    @socketIO.sockets.on 'connection', (socket) -> 
      socket.emit('connectionInfo', { hello: 'world' });

  #  @bayeux = new faye.NodeAdapter({mount: '/faye', timeout: 80 });
  #  @bayeux.attach(@app);

  whenLoggedIn: (oauth) =>
    @connectToStreaminApi(oauth)
    #window.setInterval( @connectToStreaminApi , 3600000 )

  connectToStreaminApi: (oauth) =>
    url = oauth.instance_url + '/cometd/24.0/'
    auth = oauth.access_token
    client = new faye.Client(url , {retry: 30, timeout: 300 });
    client.setHeader('Authorization', "OAuth #{auth}");
    @subscribe(client,'Cliente__c')
    @subscribe(client,'Producto__c')
    @subscribe(client,'Pedido__c')

  subscribe: (client,channel) =>
    subscription = client.subscribe "/topic/#{channel}", (message) =>
      @socketIO.sockets.emit( "/topic/#{channel}" , message );
      
      #@bayeux.getClient().publish "/topic/#{channel}" , message

    subscription.errback (error) =>
      @socketIO.sockets.emit( "connectionInfo" , error );


module.exports = SalesforceStreaming