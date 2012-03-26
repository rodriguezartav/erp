Spine   = require('spine')
Cliente = require('models/cliente')
Producto = require('models/producto')
Movimiento = require('models/movimiento')
Productos = require("controllers/productos")

$       = Spine.$

class Movimientos extends Spine.Controller
  
  events:
    "click .btn_remove"          : 'delete_movimiento'
    "click input.editable"     : "focus"
    "change input.editable"  : 'change_movimiento'

  elements: 
    'form'                        :  'form'
    ".movimiento>button"          :  "button"
    "input"                       :  "all_inputs"
    ".total"                      :  "total"
    ".cantidad:last"              : "last_cantidad"
    ".movimientos_list"           : "movimientos_list"
    ".src_producto"               : "src_producto"

  ####
  #INITIALIZERS
  ####
    
  constructor: ->
    super
    Movimiento.destroyAll()
    Producto.reset_current()
    
    @html require("views/movimientos/layouts/" + @layout  + "/layout")
    Movimiento.bind "create destroy" , @render_movimientos
    @productos = new Productos(el: @src_producto)
    
    Producto.bind "current_set"   , @add_movimiento
    
  reset: =>
    Producto.reset_current()
    @all_inputs.val("")
  
  render_movimientos: =>
    movimientos= Movimiento.all()
   
    for movimiento in movimientos     
      movimiento.ProductoName = Producto.find(movimiento.Producto).Name
   
    @movimientos_list.html require("views/movimientos/layouts/" + @layout + "/item")(movimientos)

    
  ########
  ## UI
  #########
        
  focus: (e) ->
    target = $(e.currentTarget)
    target.select()

  get_movimiento_from_index: (element) =>
    id = element.attr('data-id')
    movimiento = Movimiento.find id

  #####
  # UI LOGIC 
  #####

  movimiento_exists: (producto) =>
    for movimiento in Movimiento.all()
      if movimiento.Producto == producto.id
        return movimiento
    false

  add_movimiento: =>
    producto = Producto.current
    search_result = @movimiento_exists(producto)
    if search_result == false
      Movimiento.create_from_producto(producto)
      Producto.reset_current()
    
  change_movimiento: (e) =>
    input = $(e.target)
    movimiento = @get_movimiento_from_index input.parents('li')
    
    type = input.attr('data-type')
    min    = input.attr("data-min-value") || 1
    max    = input.attr("data-max-value")
    val = input.val()
    original_value = movimiento[type]

    if @validate(type,val,min,max)
      @do_movimiento_change(movimiento,type,val)
      input.removeClass "error"
    else
      input.val original_value
      input.addClass "error"

  do_movimiento_change: (movimiento,type,val) ->
    movimiento[type] = val
    movimiento.save()

  validate: (type,val,min,max) ->
    return false if val < min
    return false if max != null and val > max
    return false if isNaN(val) == true
    return false if parseInt(val) < 0
    true
    
  delete_movimiento: (e) =>
    target = $(e.currentTarget)
    movimiento = @get_movimiento_from_index target.parents('li')
    movimiento.destroy()    

module.exports = Movimientos