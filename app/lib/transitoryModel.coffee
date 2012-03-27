Spine ?= require('spine')

Spine.transitoryModels = [] if !Spine.transitoryModels

Spine.Model.TransitoryModel =


  extended: ->
    @change @saveLocal
    @fetch @loadLocal
    Spine.transitoryModels.push @
    
  saveLocal: ->
    result = JSON.stringify(@)
    localStorage[@className] = result

  loadLocal: ->
    result = localStorage[@className]
    @refresh(result or [], clear: true)
    
module?.exports = Spine.Model.TransitoryModel