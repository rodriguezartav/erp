Spine = require('spine')


class StatManager
  
  @registerManager: ->
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
    mixpanel.init "d7b392779910ad7a0dab3ffa716d9f68"
    false
  
  @identify: (user) =>
    mixpanel.identify(user.Email);
    mixpanel.name_tag(user.Email);
    mixpanel.register({"Perfil": "#{user.Perfil__c}" });


  #  @kmq.push(['identify', user.Email]);
    
    
  @sendEvent: (name,properties) =>
   mixpanel.track(name, properties)
   # @kmq.push(['record', name , properties]);
  

module.exports = StatManager