rest = require("restler")
querystring = require("querystring")

class RestApi

  @apiVersion = "24.0"

  @request: (options) ->
    restUrl = (if options.path.substr(0, 6) is "https:" then options.path else options.oauth.instance_url + options.path)
    reqOptions =
      method: options.method
      data: options.data
      headers:
        Accept: "application/json"
        Authorization: "OAuth " + options.oauth.access_token
        "Content-Type": "application/json"
    req = rest.request restUrl, reqOptions

    req.on "complete", (data, response) =>
      return options.error data if !response

      if response.statusCode >= 200 and response.statusCode < 300
        if data.length is 0
          options.callback()
        else
          options.callback data
      else
        options.error data
    
    #req.on "error", (data, response) =>
      #options.error data, response


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
      path: "/services/data/v" + @apiVersion + "/"
      callback: callback
      error: error

    RestApi.request options

  @describeGlobal: (oauth,callback, error) ->
    options =
      oauth: oauth
      path: "/services/data/v" + @apiVersion + "/sobjects/"
      callback: callback
      error: error

    RestApi.request options

  @identity: (oauth,callback, error) ->
    options =
      oauth: oauth
      path: "/services/data/#{oauth.id}"
      callback: callback
      error: error

    RestApi.request options

  @metadata: (oauth,data, callback, error) ->
    options =
      oauth: oauth
      path: "/services/data/v" + @apiVersion + "/sobjects/" + data.objtype + "/"
      callback: callback
      error: error

    RestApi.request options

  @describe: (oauth,data, callback, error) ->
    options =
      oauth: oauth
      path: "/services/data/v" + @apiVersion + "/sobjects/" + data.objtype + "/describe/"
      callback: callback
      error: error

    RestApi.request options

  @create: (oauth,data, callback, error) ->
    options =
      oauth: oauth
      path: "/services/data/v" + @apiVersion + "/sobjects/" + data.objtype + "/"
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
      path: "/services/data/v" + @apiVersion + "/sobjects/" + data.objtype + "/" + data.id + (if data.fields then "?fields=" + data.fields else "")
      callback: callback
      error: error

    RestApi.request options

  @upsert: (oauth,data, callback, error) ->
    options =
      oauth: oauth
      path: "/services/data/v" + @apiVersion + "/sobjects/" + data.objtype + "/" + data.externalIdField + "/" + data.externalId
      callback: callback
      error: error
      method: "PATCH"
      data: JSON.stringify(data.fields)

    RestApi.request options

  @update: (oauth, data, callback, error) ->
    options =
      oauth: oauth
      path: "/services/data/v" + @apiVersion + "/sobjects/" + data.objtype + "/" + data.id
      callback: callback
      error: error
      method: "PATCH"
      data: JSON.stringify(data.fields)

    RestApi.request options

  @del: (oauth,data, callback, error) ->
    options =
      oauth: oauth
      path: "/services/data/v" + @apiVersion + "/sobjects/" + data.objtype + "/" + data.id
      callback: callback
      error: error
      method: "DELETE"

    RestApi.request options

  @search: (oauth,data, callback, error) ->
    options =
      oauth: oauth
      path: "/services/data/v" + @apiVersion + "/search/?q=" + escape(data.sosl)
      callback: callback
      error: error

    RestApi.request options

  @query: (oauth,data, callback, error) ->
    options =
      oauth: oauth
      path: "/services/data/v" + @apiVersion + "/query/?q=" + escape(data.soql)
      callback: callback
      error: error
    RestApi.request options

  @queryMore: (oauth,data,callback,error) ->
    options =
      oauth: oauth
      path: data.nextRecordsUrl
      callback: callback
      error: error
    RestApi.request options

  @rest: (oauth,data, callback, error) ->
    path =  "/services/apexrest/#{data.restRoute}"
    path += "?#{querystring.stringify(JSON.parse(data.restData) )}" if data.restMethod == "GET"
    restData = if data.restMethod == "GET" then {} else JSON.stringify(data.restData)
    
    options =
      oauth:     oauth
      path:      path
      method:    data.restMethod
      data:      restData
      callback:  callback
      error:     error
    RestApi.request options

  @recordFeed: (oauth,data, callback, error) ->
    options =
      oauth: oauth
      path: "/services/data/v" + @apiVersion + "/chatter/feeds/record/" + data.id + "/feed-items"
      callback: callback
      error: error

    RestApi.request options

  @newsFeed: (oauth,data, callback, error) ->
    options =
      oauth: oauth
      path: "/services/data/v" + @apiVersion + "/chatter/feeds/news/" + data.id + "/feed-items"
      callback: callback
      error: error

    RestApi.request options

  @profileFeed : (oauth,data, callback, error) ->
    options =
      oauth: oauth
      path: "/services/data/v" + @apiVersion + "/chatter/feeds/user-profile/" + data.id + "/feed-items"
      callback: callback
      error: error
    RestApi.request options

module.exports = RestApi