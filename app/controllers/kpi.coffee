Spine = require('spine')
Cliente = require("models/cliente")

class KPI  extends Spine.Controller

  elements:
    ".salesBar" : "salesBar"

  constructor: ->
    super
    
    data =
      class: Cliente
      restRoute: "Kpi"
      restMethod: "GET"
      restData: {}
    
    
    Cliente.rest( data , afterSuccess: @onSuccess, afterError: @onError ) 
    
    
    
  onSuccess: (response) =>
    
    value  = (response / 300000000) * 100
    value = 1 if value < 1
    value = 100 if value > 100

    
    console.log value
    @html require("views/controllers/kpi/layout")(sales: value)
    
    

  onError:  =>  
    console.log arguments

module.exports = KPI