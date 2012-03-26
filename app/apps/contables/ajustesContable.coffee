require('lib/setup')
Spine = require('spine')
Movimientos = require("controllers/movimientos")
Documento = require("models/documento")
Cliente = require("models/cliente")
Producto = require("models/producto")
Movimiento = require("models/movimiento")
Cuenta = require("models/cuenta")
User = require("models/user")


class AjustesContable extends Spine.Controller
  className: "row"

  elements:
    "#txt_dia" : "txt_dia"
    "#txt_mes" : "txt_mes"
    "#txt_ano" : "txt_ano"
    "#txt_categoria" : "txt_categoria"
    ".error" : "error"
    ".validatable" : "inputs_to_validate"

  events:
    "click .cancel" : "reset"
    "click .save" : "send"

  constructor: ->
    super
    @error.hide()
    Cuenta.fetch_from_sf(User.current )
    Cuenta.bind "ajax_complete" , @onLoadCuenta
    @render()
    
  onLoadCuenta: =>
    @log Cuenta.all()
    @txt_categoria.html require("views/apps/contables/ajustesContables/itemCuentaGasto")(Cuenta.all())
    
  render: =>  
    @html require("views/apps/contables/ajustesContables/layout")(@documento)

  #####
  # ACTIONS
  #####
  
  update_documento: =>      
    @documento = Documento.create({Tipo: "FP"}) if !@documento
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
        @documento[type] = val
    
    #@documento.Fecha = new Date()  
    @documento.save()
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

  send: (e) =>
    return false if !@update_documento()
    @documento.AplicarACuenta = @txt_categoria.val()
    Spine.trigger "show_lightbox" , "sendDocumento" , @documento , @after_send

  after_send: =>
    @reset()
    
  
  reset: =>
    @release()
    @navigate "/apps"


module.exports = AjustesContable