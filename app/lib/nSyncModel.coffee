Spine ?= require('spine')
Spine.nSync = [] if !Spine.nSync

Spine.Model.NSyncModel =

  extended: ->
    @change @saveLocal
    @bind "query_success" , @saveLocal
    @fetch @loadLocal
    Spine.nSync.push @

    @extend
      
      beforeSaveLocal: ->
        return false;
      
      afterLoadLocal: ->
        return false;
    
      recordLastUpdate: =>
        Spine.session.setLastUpdate(@name)
        
      nSyncQueryFilter: (filter) =>
        return @queryFilterAddCondition(" LastModifiedDate >= #{Spine.session.getLastUpdate(@name).to_salesforce() }" , filter)
        
    
  saveLocal: ->
    @beforeSaveLocal()
    result = JSON.stringify(@)
    localStorage[@className] = result

  loadLocal: ->
    result = localStorage[@className]
    @refresh(result or [], clear: true)
    @afterLoadLocal()
    
    
module?.exports = Spine.Model.NSyncModel










