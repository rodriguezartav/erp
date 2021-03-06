Spine = require('spine')
Cliente = require("models/cliente")
Producto = require("models/producto")
User = require("models/user")
Saldos = require("models/socketModels/saldo")
Contacto = require("models/contacto")
ClienteFeed = require("models/clienteFeed")

class ClienteCanvas  extends Spine.Controller

  elements:
    ".clientesList" : "clientesList"
    ".searchClientes" : "searchClientes"
    ".srcCliente" : "srcCliente"
    ".srcVentas" : "srcVentas"
    ".srcProductos" : "srcProductos"
    ".srcContacto" : "srcContacto"

  events:
    "click .container" : "onClose"
    "click .btnPostToChatter" : "onPostToChatter"
    "click .btnAddContacto" : "onAddContacto"
    "click .btnEditContacto" : "onClickEditContacto"
    "click .btnSaveContacto" : "onSaveContacto"
    "click .btnDeleteContacto" : "onDeleteContacto"

  constructor: ->
    super
    Spine.bind "showClienteCanvas" , @onShowCliente
    @el.click @onClose

  onShowCliente: (cliente) =>
    document.body.style.overflow = 'hidden';
    @currentCliente = cliente

    if !cliente
      @el.show()
    else
      @html require('views/controllers/clienteCanvas/layout')
      @el.show()
      @renderContacto(cliente)
      @getClienteDetails(cliente.id)
      return name

  renderContacto: (cliente) =>
    Contacto.destroyAll()
    Contacto.createFromCliente(cliente)
    @srcCliente.html require("views/controllers/clienteCanvas/cliente")(cliente)
    @srcContacto.empty()

  onAddContacto: =>
    @srcContacto.html require('views/controllers/clienteCanvas/contacto')()

  onClickEditContacto: (e) =>
    target = $(e.target)
    contacto = Contacto.find target.data("id")
    @srcContacto.html require('views/controllers/clienteCanvas/contacto')(contacto)

  onDeleteContacto: (e) =>
    target = $(e.target)
    id = target.data "id"
    contacto = Contacto.find id
    contacto.destroy()
    cliente = @currentCliente
    cliente.Contactos = Contacto.toJson()
    cliente.save()
    cliente.ajax().update()
    @renderContacto(cliente)

  onSaveContacto: (e) =>
    target = $(e.target)
    id = target.data "id"
    contacto = Contacto.exists(id) 
    flag_newContacto = false
    if !contacto
      contacto = Contacto.create {} 
      flag_newContacto = true

    for input in $(".srcContacto > * > input")
      if !input.checkValidity()
        alert "Error en " + input.name
        contacto.destroy() if flag_newContacto
        return false

      input = $(input)
      contacto[input.data("type")] = input.val()

    contacto.save()

    cliente = @currentCliente
    return false if !cliente
    cliente.Contactos = Contacto.toJson()
    cliente.save()
    
    @renderContacto(cliente)
    
  getClienteDetails: (id) =>
    @clienteDetailId = id
    data =
      class: Cliente
      restRoute: "ClienteDetail"
      restMethod: "POST"
      restData: id: id

    Cliente.rest( data , afterSuccess: @onClienteDetailsSuccess ) 


  onClienteDetailsSuccess: (result) =>
    response = JSON.parse result.response
    pedidos = response.pedidos
    ventas = response.ventas
    pagos = response.pagos
    chatter = response.chatter

    cliente = response.cliente

    productos = []
    map={}
    for pedido in pedidos
      item = map[pedido.Producto] or { items: [] , total: 0 , semanas: {} , producto: Producto.find pedido.Producto }
      item.items.push pedido
      item.semanas[pedido.Semana] = pedido.Cantidad
      item.total += pedido.Cantidad
      map[pedido.Producto] = item


    @el.find(".srcProductos").empty()
    for index,item of map
      productos.push item
      
    productos.sort (a,b) =>
      return a.producto.CodigoExterno - b.producto.CodigoExterno
      
    @el.find(".srcProductos").html require("views/controllers/clienteCanvas/productos")(productos)
    @el.find('.lblVentaSemana').tooltip(placement: "top")

    ventas.sort (a,b) =>
      return a.Semana - b.Semana
    
    pagos.sort (a,b) =>
      return a.Semana - b.Semana
    
    labels = []
    values = []
    for venta in ventas
      labels.push venta.Semana
      values.push venta.Total / 1000000

    data = {
      labels: labels
      datasets : [
        {
          data : values
        }
      ]
    }

    ctx = $(".ventas").get(0).getContext("2d");
    new Chart(ctx).Line( data );

    labels = []
    values = []
    values2 = []
    for pago in pagos
      labels.push pago.Semana
      values.push parseInt(pago.Dias)
      values2.push pago.Monto / 1000000

    data = {
      labels: labels
      datasets : [ {data : values}]
    }

    ctx = $(".pagos").get(0).getContext("2d");
    new Chart(ctx).Line( data );

    data = {
      labels: labels
      datasets : [ {data : values2}]
    }
    ctx = $(".pagosMontos").get(0).getContext("2d");
    new Chart(ctx).Line( data );


    saldosTotal = 0
    saldos = Saldos.select (item) =>      
      return false if item.Cliente != @clienteDetailId
      return false if item.Saldo == 0
      return false if item.Tipo_de_Documento != 'FA'
      saldosTotal += item.Saldo
      return true

    saldos.sort (a,b) =>
      return a.PlazoReal() - b.PlazoReal()

    @el.find(".srcSaldos").html require("views/controllers/clienteCanvas/saldos")(saldos)
    @el.find(".saldosTotal").html parseInt(saldosTotal / 1000000)
    @el.find(".srcChatter").html require("views/controllers/clienteCanvas/chatter")(chatter)
    @el.find(".pagosDash").html require("views/controllers/clienteCanvas/pagosDash")(cliente)
    @el.find(".ventasDash").html require("views/controllers/clienteCanvas/ventasDash")(cliente)

  onInnerContainerClick: =>
    return false
    
  onPostToChatter: (e) =>
    target = $(e.target)
    target = target.parent().find "textarea"

    data =
      class: Cliente
      restRoute: "ClienteDetail"
      restMethod: "PUT"
      restData: 
        parentId: @clienteDetailId
        body: target.val()
        
    target.val ""
    chatter = Body: target.val() , parentId: @clienteDetailId
    @el.find(".srcChatter").append require("views/controllers/clienteCanvas/chatter")( [chatter] )
    Spine.trigger "show_lightbox" , "rest" , data , @after_send

  after_send: =>
    return true;

  onClose: (e) =>
    target = $(e.target)
    return false if !target.hasClass "clienteCanvas"
    document.body.style.overflow = 'scroll';
    @el.hide()

module.exports = ClienteCanvas
