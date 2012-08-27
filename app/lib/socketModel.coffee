Spine = require('spine')
Spine.socketModels = [] if !Spine.socketModels

Spine.Model.SocketModel =

  extended: ->
    @change @saveLocal
    @fetch @loadLocal
    @bind "querySuccess" , @saveBulkLocal
    
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
          console.log "got message from #{@className}"
          console.log message
          @updateFromSocket(message)

      updateFromSocket: (message) =>
        for object in message.sobjects
          delete object.attributes
        data = message.sobjects || message.objects || message.object
        results = JSON.stringify 
        @refresh results
        @afterSocketUpdate(message,results)
        console.log @
        @trigger "push_success"
        return results

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

  saveBulkLocal: ->
    @beforeSaveLocal?()
    result = JSON.stringify(@all())
    localStorage[@className] = result

  saveLocal: ->
    @beforeSaveLocal?()
    result = JSON.stringify(@)
    localStorage[@className] = result

  loadLocal: ->
    result = localStorage[@className]
    @refresh(result or [], clear: true)
    @afterLoadLocal?()

module?.exports = Spine.Model.SocketModel
