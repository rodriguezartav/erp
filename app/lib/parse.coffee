Spine  = @Spine or require('spine')
$      = Spine.$
Model  = Spine.Model

Ajax =
  getURL: (object) ->
    object and object.url?() or object.url

  enabled:  true
  pending:  false
  requests: []

  disable: (callback) ->
    if @enabled
      @enabled = false
      try
        do callback
      catch e
        throw e
      finally
        @enabled = true
    else
      do callback

  requestNext: ->
    next = @requests.shift()
    if next
      @request(next)
    else
      @pending = false

  request: (callback) ->
    (do callback).complete(=> do @requestNext)

  queue: (callback) ->
    return unless @enabled
    if @pending
      @requests.push(callback)
    else
      @pending = true
      @request(callback)
    callback

class Base
  defaults:
    contentType: 'application/json'
    dataType: 'json'
    processData: false
    
    beforeSend: (request, settings) ->
      request.setRequestHeader("X-Parse-Application-Id", Spine.parse.restKey);
      request.setRequestHeader("X-Parse-REST-API-Key"  , Spine.parse.appId);

  ajax: (params, defaults) ->
    $.ajax($.extend({}, @defaults, defaults, params))

  queue: (callback) ->
    Ajax.queue(callback)

class Collection extends Base
  constructor: (@model) ->

  custom: ( method , params , options) ->
    url = params.url || Ajax.getURL(@model)
    params.data = JSON.stringify(params.data) if params.data and typeof params.data  is "object"
    @ajax(
      params,
      type: method,
      url: url
    ).success( @customResponse(options) )
    .error( @customErrorResponse(options) )

  find: (id, params) ->
    record = new @model(id: id)
    @ajax(
      params,
      type: 'GET',
      url:  Ajax.getURL(record)
    ).success(@recordsResponse)
     .error(@errorResponse)

  all: (params) ->
    @ajax(
      params,
      type: 'GET',
      url:  Ajax.getURL(@model)
    ).success(@recordsResponse)
     .error(@errorResponse)

  fetch: (params = {}, options = {}) ->
    if id = params.id
      delete params.id
      @find(id, params).success (record) =>
        @model.refresh(record, options)
    else
      @all(params).success (records) =>
        @model.refresh(records, options)
        params.afterSuccess?()

  # Private
  customResponse: (options = {}) =>
    (data, status, xhr) =>
      @model = Spine if !@model # to allow external access
      @model.trigger('customAjaxSuccess', data, status, xhr)
      options.success?.apply( @model, [data])

  recordsResponse: (data, status, xhr) =>
    @model.trigger('ajaxSuccess', data, status, xhr)

  errorResponse: (xhr, statusText, error) =>
    @model.trigger('ajaxError', null, xhr, statusText, error)

  customErrorResponse: (options = {}) =>
    (xhr, statusText, error) =>
      @model = Spine if !@model # to allow external access
      @model.trigger('ajaxError', xhr, statusText, error)
      options.error?.apply(@model , [xhr, statusText, error] )

class Singleton extends Base
  constructor: (@record) ->
    @model = @record.constructor

  custom: (method, data, options) ->
    @queue =>
      @ajax(
        type: method
        data: JSON.stringify( data )
        url:  Ajax.getURL(@record)
      ).success(@recordResponse(options))
       .error(@errorResponse(options))

  reload: (params, options) ->
    @queue =>
      @ajax(
        params,
        type: 'GET'
        url:  Ajax.getURL(@record)
      ).success(@recordResponse(options))
       .error(@errorResponse(options))

  create: (params, options) ->    
    @queue =>
      @ajax(
        params,
        type: 'POST'
        data: JSON.stringify( @record )
        url:  Ajax.getURL(@model)
      ).success(@recordResponse(options))
       .error(@errorResponse(options))

  update: (params, options) ->
    data = @record.forSave?()
    @queue =>
      @ajax(
        params,
        type: 'PUT'
        data: JSON.stringify( data || @record)
        url:  Ajax.getURL(@record)
      ).success(@recordResponse(options))
       .error(@errorResponse(options))

  destroy: (params, options) ->
    @queue =>
      @ajax(
        params,
        type: 'DELETE'
        url:  Ajax.getURL(@record)
      ).success(@recordResponse(options))
       .error(@errorResponse(options))

  # Private

  customResponse: (options) =>
    @record.trigger('ajaxSuccess', data, status, xhr)
    options.success?.apply(@record)

  recordResponse: (options = {}) =>
    (data, status, xhr) =>
      if Spine.isBlank(data)
        data = false
      else
        data = @model.fromJSON(data)

      Ajax.disable =>
        if data
          # ID change, need to do some shifting
          if data.id and @record.id isnt data.id
            @record.changeID(data.id)

          # Update with latest data
          @record.updateAttributes(data.attributes())

      @record.trigger('ajaxSuccess', data, status, xhr)
      options.success?.apply(@record)

  errorResponse: (options = {}) =>
    (xhr, statusText, error) =>
      @record.trigger('ajaxError', xhr, statusText, error)
      options.error?.apply(@record, [xhr, statusText, error] )

# Ajax endpoint
Model.host = 'https://api.parse.com/1/classes'

Include =
  ajax: -> new Singleton(this)

  url: (args...) ->
    url = Ajax.getURL(@constructor)
    url += '/' unless url.charAt(url.length - 1) is '/'
    url += encodeURIComponent(@id)
    args.unshift(url)
    args.join('/')

Extend =
  ajax: -> new Collection(this)

  url: (args...) ->
    args.unshift(@className.toLowerCase() + 's')
    args.unshift(Model.host)
    args.join('/')

Model.Parse =
  extended: ->
    @fetch @ajaxFetch
    @change @ajaxChange

    @extend Extend
    @include Include

  # Private

  ajaxFetch: ->
    @ajax().fetch(arguments...)

  ajaxChange: (record, type, options = {}) ->
    return if options.ajax is false
    record.ajax()[type](options.ajax, options)

Model.Parse.Methods =
  extended: ->
    @extend Extend
    @include Include

Spine.registerParse= (parse) =>
  Spine.parse= parse
    #"X-Parse-Application-Id" : parse.masterKey
    #"X-Parse-REST-API-Key": parse.appId

# Globals
Ajax.defaults   = Base::defaults
Spine.Parse      = Ajax
Spine.ParseUtil = new Collection()
module?.exports = Ajax