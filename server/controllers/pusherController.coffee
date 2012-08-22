Pusher = require('node-pusher');
crypto = require("crypto")

Notificacion = require("../../app/models/notificacion")

class PusherController

  constructor: (@app) ->
    env = process.env
    @pusher = new Pusher appId: env.PUSHER_APP_ID, key: env.PUSHER_KEY , secret: env.PUSHER_SECRET
    @app.use @middleware()

  middleware: =>
    return (req,res,next)  =>
      req.pusherController = @
      next()


  register: =>
    #private-erp-feed
    #private-erp-profile


  listenFeed: =>
    #handleNotificaciones


  listenProfile: =>
    #create notifiacion , creareParse
    

  keys: =>
    apiKeys=
      restKey: process.env.PUSHER_KEY
      appId: process.env.PUSHER_APP_ID
      authUrl: process.env.PUSHER_AUTH_URL
    

  auth: (socket_id, channel, user_details) =>
    channelData = {user_id: user_details.id , user_info: user_details }
    return @pusher.auth(socket_id, channel, channelData);
    

module.exports= PusherController