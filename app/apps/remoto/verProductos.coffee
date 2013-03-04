Spine = require('spine')
Saldo = require("models/socketModels/saldo")
Producto = require("models/producto")

class VerProductos extends Spine.Controller
  
  className: "row-fluid verProductos"
  
  @departamento = "Pedidos"
  @label = "Ver Productos"
  @icon = "icon-eye-open"

  elements:
    ".productosList" : "productosList"

  events:
    "click .item_categoria" : "onCategoriaClick"
    "click .item_grupo" : "onGrupoClick"
    "click .btn_back"  : "onBackClick"

  
  setBindings: ->
 
  preset: ->

  constructor: ->
    super
    @preset()
    @setBindings()
    @html require("views/apps/remoto/productos/layout")(VerProductos)
    @renderCategorias()
    
  renderCategorias: =>
    productos = Producto.select (item) ->
      return false if !item?.Categoria or item.Activo == false or item.Categoria == "Prueba"
      return true
    categorias= (producto.Categoria for producto in productos ).unique()
    categorias = categorias.sort (a,b) ->
      if a == 'Hilco' or a == "Candados" or a == "Cerraduras"
        return -1

      return 1
    @productosList.html require("views/apps/remoto/productos/categoriaItem")(categorias)
 
  onCategoriaClick: (e) =>
    target= $(e.target)
    target = target.find "a" if !target.attr("data-name")
    name = target.attr "data-name"
    @last = ["categoria",name]
    @renderGrupos(name)

  renderGrupos: (categoria) =>
    grupos = []
    for producto in Producto.all()
      grupos.push producto.Grupo if grupos.indexOf(producto.Grupo) == -1 and producto.Categoria == categoria
    @productosList.html require("views/apps/remoto/productos/grupoItem")(grupos)

  onGrupoClick: (e) =>
    target= $(e.target)
    target = target.find "a" if !target.attr("data-name")
    name = target.attr "data-name"
    @last[0] = "grupo"
    @renderProductos(name)

  renderProductos: (grupo) =>
    productos = Producto.select (item) =>
      return true if item.Grupo == grupo
    
    productos = productos.sort (a,b) ->
      return a.CodigoExterno - b.CodigoExterno
    
    @productosList.html require("views/apps/remoto/productos/productoItem")(productos)
 
  onBackClick: =>
    return false if !@last
    if @last[0] == "grupo"
      @renderGrupos(@last[1])
      @last[0] = "categoria"
    else if @last[0] == "categoria"
      @renderCategorias()

  reset: ->
    @navigate "/apps"

module.exports = VerProductos