Spine = require('spine')

class StatManager
  
  @identified= false
  
  @registerManager: (api) ->
    return false

  @identify: (user) =>
#    Spine.statManager.identified = true
#    mixpanel.identify(user.id);
#    mixpanel.people.set 
#      "$last_login": new Date(),     
#      "Name:" : user.Name,
#      "Perfil" : user.Perfil

#    mixpanel.name_tag(user.Name);    

  @pushEvent: (name,properties) =>
 #   Spine.statManager.identify(Spine.session.user) if !Spine.statManager.identified
  #  mixpanel.track(name, properties)

  @sendEvent: (name,properties) =>
   #mixpanel?.track(name, properties)


module.exports = StatManager