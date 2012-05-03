Spine ?= require('spine')
Spine.socketModels = [] if !Spine.socketModels

Spine.Model.SocketModel =

  extended: ->
    @change @saveLocal
    @bind "query_success" , @saveLocal
    @fetch @loadLocal
    Spine.socketModels.push @

    @extend
      autoQuery            :   true
      autoQueryTimeBased   :   false
      autoPush             :   false
      
      ##SOCKETS ***************************

      beforeSocketUpdate: (results) ->
        return true

      updateFromSocket: (message) =>
        jsonLoop = JSON.stringify [message.sobject]
        results = @parseSalesforceJSON jsonLoop
        showNotification = false
        if @beforeSocketUpdate(results)
          @refresh results
          @trigger "push_success"
          console.log "Actualizacion de " + @className + " " + jsonLoop
          showNotification=true
        return showNotification

      beforeSaveLocal: ->
        return false;
      
      afterLoadLocal: ->
        return false;
    
      recordLastUpdate: =>
        Spine.session.setLastUpdate(@name)
      
        
      addLastUpdateFilter: () =>
        date = Spine.session.getLastUpdate(@name)
        try
          date.getTime()
        catch error
          date = new Date('1970/1/1')

        filter =""
        filter +=  @queryFilterAddCondition(" LastModifiedDate >= #{date.to_salesforce() }" , filter) if @autoQueryTimeBased
        return filter

  saveLocal: ->
    @beforeSaveLocal()
    result = JSON.stringify(@)
    localStorage[@className] = result

  loadLocal: ->
    result = localStorage[@className]
    @refresh(result or [], clear: true)
    @afterLoadLocal()

module?.exports = Spine.Model.SocketModel
