Spine = require('spine')

class ParseUser extends Spine.Model
  @configure 'User' , "name" , "username" , "position" ,   "email" , "updatedAt" , "aprobado" , "empresa" , "cliente" , "password"
  @extend Spine.Model.Parse  if (typeof window != 'undefined')

  @url = "/parse/users"  

  @fetch: (params  = {}, options) ->
    params.data= 'where={"username":"' + params.username + '"}' if params.username
    params.data= 'where={"pin":"' + params.pin + '"}' if params.pin
    super(params, options)

  @sendPin: (username) ->
    data=
      username: username
    Spine.ParseUtil.custom "POST" , data: data , url: "http://localhost:5000/api/1/users/sendPin"

  @checkPin: (pin) ->
    User.fetch pin

  @fromJSON: (objects) ->
    return unless objects

    if typeof objects is 'string'
      objects = JSON.parse(objects)

    objects = objects.results if objects.results      

    if Spine.isArray(objects)
      for object in objects
        
        if object.objectId
          object.id = object.objectId
          delete object.objectId
      (new @(value) for value in objects)
    else
      objects.id = objects.objectId if objects.objectId
      new @(objects)

  forSave: () =>
    data =
      "username"  : @username
      "name"      : @name
      "position"  : @position
      "pin"       : @pin
      "email"     : @email
      "aprobado"  : @aprobado
      "empresa"   : @empresa
      "cliente"   : @cliente
      "password"  : @password
    data

module.exports = ParseUser