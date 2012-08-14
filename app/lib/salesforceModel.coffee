Spine = require "spine"

Spine.Model.SalesforceModel =

  extended: ->

    @extend 
      avoidQueryList: []
      avoidInsertList: []
      standardObject: false
      overrideName: null
      standardFields: ["LastModifiedDate","Name"]
      lastUpdate: new Date(1000)
      
      fromJSON: (objects) ->
        return unless objects
        if typeof objects is 'string'
          objects = objects.replace(new RegExp("__c", 'g'),"")
          objects = objects.replace(new RegExp("Id", 'g'),"id")
          objects = JSON.parse(objects)
        objects = objects.records if objects.records

        if Spine.isArray(objects)
          for value in objects
            cDate = if value.LastModifiedDate then new Date(value.LastModifiedDate) else new Date(1000)
            @lastUpdate = cDate if cDate > @lastUpdate.getTime()
            obj = new @(value)
            obj
        else
          new @(objects)

      getQuery: (options) =>
        @queryOrderString  = ""
        @queryFilterString = ""
        @queryFilter(options)
        if @autoQueryTimeBased or ( options and !options.avoidQueryTimeBased )
          @queryFilterAddCondition " LastModifiedDate >= #{@lastUpdate.to_salesforce()}" 
        return @queryString() + @queryFilterString + @queryOrderString

      queryOrderAddCondition: (order) =>
        @queryOrderString += " #{order} "

      queryFilterAddCondition: (condition) =>
        if @queryFilterString.indexOf("where") == -1
          @queryFilterString += " where " 
        else
          @queryFilterString += " and "
        @queryFilterString += " #{condition} "

      queryFilter: (options) =>
        @queryFilterString = "" if !options

      queryString: (options) =>
        className = @overrideName || @className 
        query = "select "
        for attribute in @attributes
          if @avoidQueryList?.indexOf(attribute) == -1            
            query += attribute
            if @standardObject or @standardFields.indexOf(attribute) > -1
              query += ","
            else
              query += "__c,"

        query += "Id  "
        query +=  "from #{className}" 
        query +=  "__c"  if !@standardObject 
        query += " "
        query


module.exports = Spine.Model.SalesforceModel