#INCLUDES THE NECCESARY METHODS AND EVENTS TO QUERY AND INSERT OBJECTS TO SALESFORCE
#IT IS ALSO INTEGRATED WITH OTHER PLUGINS LIKE SYNCRONIZABLE, IF IT IS NOT INCLUDED THEN NO PROBLEM

Spine ?= require('spine')

StatManager = require("managers/statManager")

Spine.salesforceQueryQueue = 0

Spine.Model.Salesforce =

  extended: ->

    @extend 
      avoidQueryList: []
      avoidInsertList: []
      standardObject: false
      overrideName: null

      ajaxParameters: (params) ->
         params.instance_url= Spine.session.instance_url
         params.token= Spine.session.token
         params.host= Spine.session.host
         params


    ##INSERT ***************************
      
      salesforceFormat: (items) =>  
        objects = []
        for item in items
          object = {}
          for attr of item.attributes()
            if @avoidInsertList.indexOf(attr) == -1
              object[attr + "__c" ] = item[attr] if attr != "id"
          objects.push object
        requests = JSON.stringify( objects )  
        requests

      sendUrl: (items) =>
        url = if items.length == 1 then url = "/save" else "/save/bulk"
        return Spine.server + url

      beforeInsert: () ->
        return false


      beforeRest: () ->
        return false


      rest: (name,method,jsonObject) ->
        @beforeRest
        StatManager.sendEvent 'Action' , { type: "Rest" , class: name }
        
        $.ajax
          url        : Spine.server + "/rest"
          xhrFields  : {withCredentials: true}
          type       : method
          data       : @ajaxParameters( { name: "Oportunidad" , data: jsonObject } )
          success    : @on_send_success
          error      : @on_send_error
        
        
      insert: (documentos,url) =>
        @beforeInsert()
        className = @overrideName || @className 
        ##STAT  
        StatManager.sendEvent 'Action' , { type: "Save" , class: className }
        
        $.ajax
          url        : @sendUrl(documentos)
          type       : "POST"
          data       : @ajaxParameters( { type: "#{className}__c" , items: @salesforceFormat(documentos) } )
          success    : @on_send_success
          error      : @on_send_error

      on_send_success: (raw_results) =>
        results = JSON.parse raw_results
        @trigger "insert_success" , results

      on_send_error: (error) =>
        responseText = error.responseText
        if responseText.length > 0
          #If session expired
            #return Spine.trigger("show_lightbox","login")
          errors = JSON.parse responseText
        else
          errors = { type:"LOCAL" , error: " Indefinido: Posiblemente Problema de Red", source: "Pedido" }
        @trigger "insert_error" , errors
    
    
    ##QUERY ***************************

      queryFilterAddCondition: (condition,filter) ->
        if filter.indexOf("where") == -1
          filter += " where " 
        else
          filter += " and "
        filter += " #{condition} "
      
      queryFilter: (options) =>
        return "" if !options
        filter = ""
      
      queryString: =>
        className = @overrideName || @className 
      
        query = "select "
        for attribute in @attributes
          if @avoidQueryList?.indexOf(attribute) == -1
            query += attribute
            if attribute.indexOf("Name") == -1 || @standardObject then query += "__c,"  else query += ","
        query += "Id "
        query +=  "from #{className}" 
        query +=  "__c"  if !@standardObject 
        query += " "
        query

      query: (options = false ) =>
        Spine.salesforceQueryQueue +=1
        query = @queryString()
        query += @queryFilter(options)
        query += @addLastUpdateFilter() if @addLastUpdateFilter
        Spine.trigger "query_start"
        $.ajax
          url: Spine.server + "/query"
          xhrFields: {withCredentials: true}
          type: "POST"
          data: @ajaxParameters({query: query})
          success: @on_query_success
          error: @on_query_error
          complete: @on_query_complete

      on_query_complete:  ->
        Spine.salesforceQueryQueue -=1
        Spine.trigger "query_complete"

      parseSalesforceJSON: (raw_results) ->
        raw_results = String.replaceAll(raw_results,'__c','') if !@standardObject
        raw_results = String.replaceAll(raw_results,'Id','id')
        objects = JSON.parse(raw_results)
        results = if objects.results then objects.results else objects
        results

      on_query_success: (raw_results) =>
        results = @parseSalesforceJSON(raw_results)
        @destroyAll() if @destroyBeforeRefresh
        @refresh(results)        
        @trigger "query_success"
        @recordLastUpdate?()

      on_query_error: (error) =>
        console.log error
        #alert responseText  = error.responseText
        responseText  = error.responseText
        if responseText.length > 0
          if responseText.toLowerCase().indexOf("session expired") > -1
            return Spine.trigger("show_lightbox","login",null, -> window.location.reload() )
          errors = JSON.parse responseText
        else
          errors = {type:"LOCAL" , error: " Indefinido: Posiblemente Problema de Red", source: "Cliente" }
        @trigger "query_error" , errors
      

module?.exports = Spine.Model.Salesforce

