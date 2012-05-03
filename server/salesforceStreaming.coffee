faye = require 'faye'
OPF = require("opf")


class SalesforceStreaming

  constructor: (@app) ->
    @bayeux = new faye.NodeAdapter({mount: '/faye', timeout: 80 });
    @bayeux.attach(@app);

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
      @bayeux.getClient().publish "/topic/#{channel}" , message

    subscription.errback (error) ->
      console.log error.message

module.exports = SalesforceStreaming