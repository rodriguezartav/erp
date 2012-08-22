Spine = require "spine"

Spine.Model.SalesforceModel =

  extended: ->

    @extend 
      avoidQueryList: []
      avoidInsertList: []
      standardObject: false
      autoQueryTimeBased: false
      overrideName: null
      standardFields: ["LastModifiedDate","Name"]
      lastUpdate: new Date(1000)

      salesforceFormat: (items,includeId = false) =>
        items = [items] if !Spine.isArray(items)
        objects = []
        for item in items
          objects.push @sobjectFormat(item,includeId)
        objects

      sobjectFormat: (item, includeId=false) =>
        object = {}
        for attr of item.attributes()
          if @avoidInsertList.indexOf(attr) == -1
            object[attr + "__c" ] = item[attr] if @standardFields.indexOf(attr) == -1 and attr != "id"
            object["Id"] = item[attr] if attr == "id" and includeId
        return object

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
        if @autoQueryTimeBased or ( options and options.avoidQueryTimeBased == false )
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