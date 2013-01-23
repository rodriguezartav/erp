Spine = require('spine')


class StatManager
  
  @registerManager: (api) ->
    #@setupSegment()
    return false;
  
  @setupSegment: =>
    # Create a queue, but don't obliterate an existing one!
    analytics = analytics or []

    # Define a method that will asynchronously load analytics.js from our CDN.
    analytics.load = (apiKey) ->

      # Create an async script element for analytics.js.
      script = document.createElement("script")
      script.type = "text/javascript"
      script.async = true
      script.src = ((if "https:" is document.location.protocol then "https://" else "http://")) + "d2dq2ahtl5zl1z.cloudfront.net/analytics.js/v1/" + apiKey + "/analytics.min.js"

      # Find the first script element on the page and insert our script next to it.
      firstScript = document.getElementsByTagName("script")[0]
      firstScript.parentNode.insertBefore script, firstScript

      # Define a factory that generates wrapper methods to push arrays of
      # arguments onto our `analytics` queue, where the first element of the arrays
      # is always the name of the analytics.js method itself (eg. `track`).
      methodFactory = (type) ->
        ->
          analytics.push [type].concat(Array::slice.call(arguments, 0))


      # Loop through analytics.js' methods and generate a wrapper method for each.
      methods = ["identify", "track", "trackLink", "trackForm", "trackClick", "trackSubmit", "pageview", "ab", "alias"]
      i = 0

      while i < methods.length
        analytics[methods[i]] = methodFactory(methods[i])
        i++


    # Load analytics.js with your API key, which will automatically load all of the
    # analytics integrations you've turned on for your account. Boosh!
    analytics.load "studpw6gry"
    Spine.analytics = analytics
  
  
  @obsolete: ->
    ((d, c) ->
      a = undefined
      b = undefined
      g = undefined
      e = undefined
      a = d.createElement("script")
      a.type = "text/javascript"
      a.async = not 0
      a.src = (if "https:" is d.location.protocol then "https:" else "http:") + "//api.mixpanel.com/site_media/js/api/mixpanel.2.js"
      b = d.getElementsByTagName("script")[0]
      b.parentNode.insertBefore a, b
      c._i = []
      c.init = (a, d, f) ->
        b = c
        (if "undefined" isnt typeof f then b = c[f] = [] else f = "mixpanel")
        g = "disable track track_pageview track_links track_forms register register_once unregister identify name_tag set_config".split(" ")
        e = 0
        while e < g.length
          ((a) ->
            b[a] = ->
              b.push [ a ].concat(Array::slice.call(arguments, 0))
          ) g[e]
          e++
        c._i.push [ a, d, f ]

      window.mixpanel = c
    ) document, []
    mixpanel.init api #"d7b392779910ad7a0dab3ffa716d9f68"
    false
  
  @identify: (user) =>
    mixpanel?.identify(user.Email);
    #mixpanel.name_tag(user.Email);
    #mixpanel.register({"Perfil": "#{user.Perfil__c}" });
  #  @kmq.push(['identify', user.Email]);
    
    
  @pushEvent: (name,properties) =>
    mixpanel?.track(name, properties)


  @sendEvent: (name,properties) =>
   #mixpanel.track(name, properties)
   # @kmq.push(['record', name , properties]);
  

module.exports = StatManager