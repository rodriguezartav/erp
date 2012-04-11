Spine ?= require('spine')
Spine.nSync = [] if !Spine.nSync

Spine.Model.NSyncModel =

  extended: ->
    @change @saveLocal
    @bind "query_success" , @saveLocal
    @fetch @loadLocal
    Spine.nSync.push @

    @extend
      
      autoQuery: true
      
      beforeSaveLocal: ->
        return false;
      
      afterLoadLocal: ->
        return false;
    
      recordLastUpdate: =>
        Spine.session.setLastUpdate(@name)
        
      nSyncQueryFilter: (filter) =>
        date = Spine.session.getLastUpdate(@name)
        if typeof date != "Date"
          date = new Date('1970/1/1')
        return @queryFilterAddCondition(" LastModifiedDate >= #{date.to_salesforce() }" , filter)
        
    
  saveLocal: ->
    @beforeSaveLocal()
    result = JSON.stringify(@)
    localStorage[@className] = result

  loadLocal: ->
    result = localStorage[@className]
    @refresh(result or [], clear: true)
    @afterLoadLocal()
    
    
module?.exports = Spine.Model.NSyncModel










