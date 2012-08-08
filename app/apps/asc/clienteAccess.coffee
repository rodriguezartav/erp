Spine = require('spine')
Cliente = require("models/cliente")
Clientes = require("controllers/clientes")
Documento = require("models/documento")
ParseUser = require("models/parse/parseUser")

Pago = require("models/transitory/pago")
PagoItem = require("models/transitory/pagoItem")

class Items extends Spine.Controller  
  @extend Spine.Controller.ViewDelegation
  tag: "tr"
  className: "item"

  elements:
    ".validatable" : "inputs_to_validate"

  events:
    "click .remove"    : "removeUser"
    "click .aprobar"   : "aprobarUser"
    "click .noAprobar" : "noAprobarUser"
    "click .sendPin"   : "sendPin"

  constructor: ->
    super
    @render()
    
  render: =>
    @html require("views/apps/asc/user")(@user)
    @el.attr "data-cliente" , @user.cliente

  removeUser: ->
    @user.destroy()
    @reset()

  aprobarUser: ->
    @user.aprobado= true;
    @user.save()
    @render()
    Spine.socketManager.push "custumer_aproval" , { user: @user }

  noAprobarUser: ->
    @user.aprobado= false;
    @user.save()
    @render()
    
  sendPin: ->
    ParseUser.sendPin @user.username
    alert "Se envio el pin"

class ClienteAccess extends Spine.Controller
  className: "row-fluid"
  
  @departamento = "Servicio"
  @label = "Acceso de Clientes"
  @icon = "icon-remove"
  
  elements:
    ".userList"    : "userList"
    ".src_cliente" : "src_cliente"  
    ".input"       : "inputs"
    
  events:
    "submit .createUserForm" : "onSubmitUserForm"
  
  setVariables: ->
    @items = []

  setBindings: ->
    ParseUser.bind 'refresh' , @onUserLoaded
    Cliente.bind 'current_set' , @onClienteSet

  resetBindings: ->
    ParseUser.unbind 'refresh' , @onUserLoaded
    Cliente.unbind 'current_set' , @onClienteSet

  preset: ->
    Cliente.reset()
 
  constructor: ->
    super
    @preset()
    @setVariables()
    @render()
    @setBindings()
   
  render: =>
    @html require("views/apps/asc/layout")(ClienteAccess)
    ParseUser.fetch()
    @clientes = new Clientes(el: @src_cliente)

  onClienteSet: (cliente) =>
    @inputs.val ""
    @el.find("tr.item").hide()
    rows = @el.find("tr.item[data-cliente='#{cliente.CodigoExterno}']")
    rows.show()
      

  onSubmitUserForm: (e) ->
    e.preventDefault()
    return if !Cliente.current
    user = ParseUser.fromForm(e.target)
    user.empresa = Cliente.current.Name
    user.cliente = "#{Cliente.current.CodigoExterno}"
    user.password = "rodco911"
    user.save()
    @createItem(user)

  onUserLoaded: =>
    users = ParseUser.all()
    users= users.sort (a,b) ->
      return Date.parse(b.updatedAt) - Date.parse(a.updatedAt)
    for user in users
      @createItem(user)

  createItem: (user) =>
    item = new Items(user: user)
    @items.push item
    @userList.append item.el    

  reset: ->
    @resetBindings()
    @release()
    @navigate "/apps"


    
module.exports = ClienteAccess