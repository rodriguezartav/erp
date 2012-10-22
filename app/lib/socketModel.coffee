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
          console.log "getting message from #{name}__c"
          @updateFromSocket(message)

      updateFromSocket: (message) =>
        for object in message.sobjects
          delete object.attributes
        #console.log @
        #console.log message
        data = message.sobjects || message.objects || message.object
        results = JSON.stringify
        console.log results 
        console.log @refresh(results)
        @afterSocketUpdate(message,results)
        @trigger "push_success"
        return results

      afterSocketUpdate: (message,results) =>
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
        Spine.trigger "bulkProgress" , [start , @source.length]
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
