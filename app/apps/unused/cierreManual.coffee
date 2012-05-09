Spine   = require('spine')
User = require('models/user')
Cierre = require('models/cierre')
$       = Spine.$

class CierreManual extends Spine.Controller
  className: 'cierreManual modal'

  elements:
    ".alert-box" : "alert_box"
    ".loader" : "loader"
    ".validatable" : "inputs_to_validate"

  events:
    "click .save" : "save"
    "click .cancel" : "cancel"

  @type = "cierreManual"

  constructor: ->
    super
    @cierre = @data
    @html require('views/lightbox/cierreManual')  

  update_documento: =>      
    for input in @inputs_to_validate
      input = $(input)
      min = input.attr("data-min-length") || 1
      writable = input.attr("data-modify-object") || true
      required = input.attr("data-required") || true
      type = input.attr("date-type")
      numeric =input.attr("data-numeric") || false
      positive = input.attr("data-positive") || false
      val = input.val() || ""
      min = 0 if required == false

      errors = @validate(type,val,min,numeric,positive)
      if errors.length > 0
        input.addClass "error"
        @prepend require("views/alert")({message: errors.join('<br/>') })
        return false
      else if writable == true
        input.removeClass "error"
        @cierre[type] = val
    
    return true

  validate: (type,val,min,numeric,positive) ->
    error = []
    if val.length < min
      error.push "Ingrese un valor para " + type 
    else if isNaN(val) and numeric 
      error.push "El campo " +  type + " campo debe ser numerico" 
    else if val < 0  and positive 
      error.push "El campo " +  type + " campo debe ser positivo"
    error
   
  save: (results) =>
    if @updateDocumento()
      @cierre.parseFromDate()
      @callback.apply @, [true]
      Spine.trigger "hide_lightbox"

  cancel: (error_obj) =>  
    @cierre.inventariosInicial = 0
    @cierre.ventasInicial = 0
    @cierre.saldosInicial = 0
    @cierre.pagosInicial =  0
    @cierre.saldosProveedorInicial =  0
    @callback.apply @, [false]
    Spine.trigger "hide_lightbox"
    
module.exports = CierreManual