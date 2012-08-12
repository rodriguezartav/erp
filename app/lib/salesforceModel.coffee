Spine = require "spine"

Spine.Model.SalesforceModel =

  extended: ->

    @extend 
      avoidQueryList: []
      avoidInsertList: []
      standardObject: false
      overrideName: null
      
      fromJSON: (objects) ->
        return unless objects
        if typeof objects is 'string'
          objects = objects.replace(new RegExp("__c", 'g'),"")
          objects = objects.replace(new RegExp("Id", 'g'),"id")
          objects = JSON.parse(objects)
        objects = objects.records if objects.records

        if Spine.isArray(objects)
          (new @(value) for value in objects)
        else
          new @(objects)
      
      getQuery: (options) =>
        @queryOrderString  = ""
        @queryFilterString = ""
        @queryFilter(options)
        if @autoQueryTimeBased or ( options and !options.avoidQueryTimeBased )
          @queryFilterAddCondition " LastModifiedDate >= #{Spine.session.getLastUpdateOr1970(@name).to_salesforce() }" 
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
            if @standardObject
              query += ","
            else if attribute.indexOf("Name") == 0 
              query += ","
            else
              query += "__c,"

        query += "Id "
        query +=  "from #{className}" 
        query +=  "__c"  if !@standardObject 
        query += " "
        query


module.exports = Spine.Model.SalesforceModel