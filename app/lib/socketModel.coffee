Spine = require('spine')
Spine.socketModels = [] if !Spine.socketModels

Spine.Model.SocketModel =

  extended: ->
    @change @saveLocal
    @bind "query_success" , @saveLocal
    @fetch @loadLocal
    Spine.socketModels.push @
    
    @extend
      autoQuery            :   false
      autoQueryTimeBased   :   false
      autoPush             :   false
      allowCreate          :   true
      allowUpdate          :   true
      
      ##SOCKETS ***************************

      registerForUpdate: (channel) =>
        name = @overrideName || @className
        channel.bind "#{name}__c" , (message) =>
          @updateFromSocket(message)

      beforeSocketUpdate: (results) ->
        for result in results
          alert "REPORTE ESTE ERROR: Se esta actualizando sin ID : "  + JSON.stringify result if !result.id
          result = {}
        return true

      updateFromSocket: (message) =>
        for object in message.sobjects
          delete object.attributes
        jsonLoop = JSON.stringify message.sobjects
        results = @parseSalesforceJSON jsonLoop
        if @beforeSocketUpdate(results)
          @refresh results
          @afterSocketUpdate(message,results)
          @trigger "push_success"
          return results
        return false

      afterSocketUpdate: (message,results) =>
        console.log "updated #{@className}"
        return true

      beforeSaveLocal: ->
        return false;
      
      afterLoadLocal: ->
        return false;
    
      recordLastUpdate: =>
        Spine.session.setLastUpdate(@name)

      bulkDelete: =>
        @source = @all()
        start = @source.length - 20
        start = 0 if start < 0
        to_work = @source.slice(start)
        console.log "Starting from " + start + " of " + @source.length
        @source = @source.slice(0,start)
        for item in to_work
          item.destroy()
        setTimeout(@bulkDelete, 135) if @source.length > 0
        @trigger "bulk_deleted" if @source.length == 0

      forceDelete: ->
        localStorage[@className] = []

  saveLocal: ->
    @beforeSaveLocal()
    result = JSON.stringify(@)
    localStorage[@className] = result

  loadLocal: ->
    result = localStorage[@className]
    @refresh(result or [], clear: true)
    @afterLoadLocal()

module?.exports = Spine.Model.SocketModel
