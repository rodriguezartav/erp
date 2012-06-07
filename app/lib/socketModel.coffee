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
      allowCreate          :   true
      allowUpdate          :   true
      
      ##SOCKETS ***************************

      beforeSocketUpdate: (results) ->
        return true

      allowAction: (action) ->
        if (@allowCreate and action == "created") or (@allowUpdate and action=="updated")
          return true
        return false

      updateFromSocket: (message) =>
        jsonLoop = JSON.stringify [message.sobject]
        results = @parseSalesforceJSON jsonLoop
        if @beforeSocketUpdate(results) and @allowAction(message.event.type)
          @refresh results
          @trigger "push_success"
          #console.log "Actualizacion de " + @className + " " + jsonLoop
          return results
#        else
 #         console.log "No se actualizo por #{@allowedPushActions} y #{message.event}" 
        return false

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

  saveLocal: ->
    @beforeSaveLocal()
    result = JSON.stringify(@)
    localStorage[@className] = result

  loadLocal: ->
    result = localStorage[@className]
    @refresh(result or [], clear: true)
    @afterLoadLocal()

module?.exports = Spine.Model.SocketModel
