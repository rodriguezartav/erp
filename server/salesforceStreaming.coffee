OPF = require("opf")
#SocketIO = require('socket.io')
Faye = require 'faye'
Pusher = require('node-pusher');


class SalesforceStreaming

  constructor: (@app) ->
    @pusher = new Pusher
      appId: '19854',
      key: 'a8cfc9203fbabab7e67f',
      secret: 'dac21dde46d73add4aa3'

  whenLoggedIn: (oauth) =>
    @pusher.trigger "salesforce_connection_information" , 'connect' , {"message": "Connection Established with Server"}
    
    url = oauth.instance_url + '/cometd/24.0/'
    auth = oauth.access_token
    @fayeClient = new Faye.Client(url , {retry: 60, timeout: 300 });
    @fayeClient.setHeader('Authorization', "OAuth #{auth}");
    @subscribe('Cliente__c')
    @subscribe('Producto__c')
    @subscribe('Pedido__c')
    @subscribe('Docmento__c')

  subscribe: (channel) =>
    subscription = @fayeClient.subscribe "/topic/#{channel}", (message) =>      
      @pusher.trigger "salesforce_data_push" , channel , message

    subscription.errback (error) =>
      @pusher.trigger "salesforce_connection_information" , 'error', {"message": "There was an error in the Server- Salesforce Connection " , "error": "#{error}"}

module.exports = SalesforceStreaming