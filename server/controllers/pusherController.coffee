Pusher = require('node-pusher');
crypto = require("crypto")

class PusherController

  constructor: (@app) ->
    env = process.env
    @pusher = new Pusher appId: env.PUSHER_APP_ID, key: env.PUSHER_KEY , secret: env.PUSHER_SECRET
    @app.use @middleware()

  middleware: =>
    return (req,res,next)  =>
      req.pusherController = @
      next()

  auth: (socketId, channel, channelData) =>
    returnHash = {}
    channelDataStr = ''
    if channelData
      channelData = JSON.stringify(channelData);
      channelDataStr = ':' + channelData;
      returnHash['channel_data'] = channelData;

    stringToSign = socketId + ':' + channel + channelDataStr;
    returnHash['auth'] = process.env.PUSHER_KEY + ':' + crypto.createHmac('sha256', process.env.PUSHER_SECRET).update(stringToSign).digest('hex');
    returnHash
  

module.exports= PusherController