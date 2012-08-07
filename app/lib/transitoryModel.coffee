Spine = require('spine')

# THIS IS AN ADD ON FOR MODELS THAT MUST BE PERSISTED LOCALLY AND WANT TO BE FETCH TOGHETER USING THE SPINE.TRANSITORYMODEL
# IT ALSO SEPARATES DE LOCALSTORAGE KEY WITH TRANSITORY, ITS USUALLY USED FOR DRAFT OBJECTS

Spine.transitoryModels = [] if !Spine.transitoryModels

Spine.Model.TransitoryModel =


  extended: ->
    @change @saveLocal
    @fetch @loadLocal
    Spine.transitoryModels.push @
    
  saveLocal: ->
    result = JSON.stringify(@)
    localStorage["Transitory_" + @className] = result

  loadLocal: ->
    result = localStorage["Transitory_" + @className]
    @refresh(result or [], clear: true)
    
module?.exports = Spine.Model.TransitoryModel