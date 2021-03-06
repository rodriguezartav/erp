#INCLUDES THE NECCESARY METHODS AND EVENTS TO QUERY AND INSERT OBJECTS TO SALESFORCE
#IT IS ALSO INTEGRATED WITH OTHER PLUGINS LIKE SYNCRONIZABLE, IF IT IS NOT INCLUDED THEN NO PROBLEM

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
      Spine.statManager.pushEvent "API Call" , @url

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

  all: (filters,params) ->
    @ajax(
      params,
      type: 'GET',
      dataType: "text" ,
      url:  "/salesforce/sobjects?soql=#{@model.getQuery(filters)}"
    ).success(@recordsResponse)
     .error(@errorResponse)
     .error =>
       console.log arguments
       Spine.queries -= 1
       Spine.trigger "queryComplete"

  query: (filters , params = {}, options = {}) ->
    Spine.trigger "queryBegin"
    Spine.queries += 1
    @all(filters , params).success (records) =>
      @model.destroyAll() if @model.destroyBeforeRefresh
      @model.refresh(records, options)
      Spine.queries -= 1 
      @model.trigger "querySuccess"
      Spine.trigger "queryComplete"
      params.afterSuccess?(records)
      @model.onQuerySuccess?()

  rest: (params,options = {}) =>
    @beforeRest
    data={}
    if params.restMethod == 'GET'
      data = "restRoute=#{params.restRoute}&restData=#{JSON.stringify(params.restData)}&restMethod=GET"
    else
      data = JSON.stringify { restRoute: params.restRoute , restData: params.restData , restMethod: params.restMethod } 
    
    
    Spine.statManager.pushEvent "REST Call" , params.restRoute

    request = @ajax(
      params,
      type:  params.restMethod,
      data:  data
      url:   "/salesforce/rest"
    ).success(@recordsResponse)
     .error(@errorResponse)
     request.error (error) =>
       options.afterError?(error)
    request.success (records) =>
      options.afterSuccess?(records)

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

    if xhr.status == "503"
      Spine.trigger "show_lightbox" , "showWarning" , error: "Su session ha expirado, vamos a cargar la pagina otra vez" , ->
        window.location.reload();


  customErrorResponse: (options = {}) =>
    (xhr, statusText, error) =>
      @model = Spine if !@model # to allow external access
      @model.trigger('ajaxError', xhr, statusText, error)
      options.error?.apply(@model , [xhr, statusText, error] )

class Singleton extends Base
  constructor: (@record) ->
    @model = @record.constructor
    type = "#{ @model.overrideName or @model.name}"
    type += "__c" if !@model.standardObject
    @obj = 
       fields: @model.sobjectFormat(@record , false)
       id: @record.id
       objtype: type

  custom: (method, data, options={}) ->
    @queue =>
      request = @ajax(
        type: method
        data: JSON.stringify( @obj )
        url:  Ajax.getURL(@record)
      ).success(@recordResponse(options))
       .error(@errorResponse(options))

      request.error (error) =>
        options.afterError?()

      request.success (records) =>
        options.afterSuccess?()

  reload: (params, options={}) ->
    @queue =>
      request = @ajax(
        params,
        type: 'GET'
        url:  Ajax.getURL(@record)
      ).success(@recordResponse(options))
       .error(@errorResponse(options))

      request.error (error) =>
        options.afterError?()

      request.success (records) =>
        options.afterSuccess?()

  create: (params, options={}) ->
    @queue =>
      request = @ajax(
        params,
        type: 'POST'
        data: JSON.stringify @obj
        url:  Ajax.getURL(@model)
      ).success(@recordResponse(options))
       .error(@errorResponse(options))

      request.error (error) =>
        options.afterError?()

      request.success (records) =>
        options.afterSuccess?()

  update: (params, options={}) ->
    @queue =>
      request = @ajax(
        params,
        type: 'PUT'
        data: JSON.stringify(@obj)
        url:  Ajax.getURL(@record)
      ).success(@recordResponse(options))
       .error(@errorResponse(options))

      request.error (error) =>
        options.afterError?(error)

      request.success (records) =>
       options.afterSuccess?(records)
    

  destroy: (params, options={}) ->
    @queue =>
      request = @ajax(
        params,
        type: 'DELETE'
        url:  Ajax.getURL(@record)
      ).success(@recordResponse(options))
       .error(@errorResponse(options))

      request.error (error) =>
        options.afterError?()

      request.success (records) =>
        options.afterSuccess?()


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
      
      if xhr.status == "503"
        Spine.trigger "show_lightbox" , "showWarning" , error: "Su session ha expirado, vamos a cargar la pagina otra vez" , ->
          window.location.reload();
        

# Ajax endpoint
Model.host = '/salesforce/sobjects'

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

Model.SalesforceAjax =
  extended: ->
    @change @ajaxChange

    @extend Extend
    @include Include

  # Private

  query: ->
    @ajax().query(arguments...)

  rest: ->
    @ajax().rest(arguments...)

  ajaxChange: (record, type, options = {}) ->
    return if options.ajax is false
    record.ajax()[type](options.ajax, options)

Model.SalesforceAjax.Methods =
  extended: ->
    @extend Extend
    @include Include
    
  rest: ->
    @ajax().rest(arguments...)

# Globals
Ajax.defaults   = Base::defaults
Spine.SalesforceAjax      = Ajax
Spine.SalesforceAjaxUtil = new Collection()
Spine.queries = 0
module?.exports = Ajax
