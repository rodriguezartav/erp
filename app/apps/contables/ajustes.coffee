require('lib/setup')
Spine = require('spine')
Ajuste = require("models/ajuste")
Cuenta = require("models/cuenta")


class Items extends Spine.Controller
  @extend Spine.Controller.ViewDelegation
  
  tag: "tr"

  elements:
    ".validatable" : "inputs_to_validate"

  events:
    "click .js_btn_remove" : "reset"
    "change input" : "checkItem"
    
  constructor: ->
    super
    @ajuste = { Cuenta: @cuenta , Credito: 0 , Debito: 0, Detalle: '' }
    @html require("views/apps/contables/ajustes/item")(@ajuste)

  checkItem: (e) =>
    @updateFromView(@ajuste,@inputs_to_validate)
    throw "No se pueden ingresar creditos y debitos" if @ajuste.Credito != 0 and @ajuste.Debito != 0
    Ajuste.trigger "updateTotal"

  reset: =>
    @ajuste = null
    @release()

class Ajustes extends Spine.Controller
  @extend Spine.Controller.ViewDelegation
  className: "row-fluid"

  @departamento = "Contabilidad"
  @label = "Ajustes Contables"
  @icon = "icon-refresh"

  className: "row-fluid"

  elements:
    ".validatable"     :  "inputs_to_validate"
    ".items"           :  "items"
    ".lblCredito"      : "lblCredito"
    ".lblDebito"       : "lblDebito"
    ".lblBalance"      : "lblBalance"
    ".detalle"         : "detalles"
    
  events:
    "click .cancel"    :  "reset"
    "click .save"      :  "send"

  setBinding: =>
    Cuenta.bind "query_success" , @onLoadCuenta
    Cuenta.bind "selected" , @addItem
    Ajuste.bind "updateTotal" , @updateTotal
    
  resetBinding: =>
    Cuenta.unbind "query_success" , @onLoadCuenta
    Cuenta.unbind "selected" , @addItem
    Ajuste.unbind "updateTotal" , @updateTotal


  constructor: ->
    super
    Ajuste.destroyAll()
    @ajustes = []
    @itemToControllerMap = {}
    @balance = 0
    @html require("views/apps/contables/ajustes/layout")(@constructor)
    Cuenta.query({ clases: "'Gasto','Activo','Costo de Venta','Patrimonio','Ingreso'" } )
    @setBinding()

  onLoadCuenta: =>
    $('.typeAhead').typeahead({source: Cuenta.all() , matcher: @filterCuentas ,sorter: @sortCuentas, highlighter: @highlightCuentas })
    
    $('.typeAhead').click ->
      $('.typeAhead').data('typeahead').show()

    $('.typeAhead').data('typeahead').select = ->
      val = @$menu.find('.active').attr('data-value')
      Cuenta.trigger "selected" , val
      return @hide()
    
  filterCuentas: (item) ->
    return true if item.Codigo.indexOf(@query) == 0
    return true if item.Name.toLowerCase().indexOf(@query.toLowerCase() ) > -1
    return false
    
  sortCuentas: (items) ->  
    return items;
  
  highlightCuentas: (item) =>
    return item.Codigo + ' ' + item.Name
  
  addItem: (cuentaRaw)  =>
    cuenta = JSON.parse cuentaRaw
    exists = @itemToControllerMap[cuenta.id]
    if(!exists and cuenta.Automatica == false)
      item = new Items(cuenta: cuenta)
      @ajustes.push item
      @itemToControllerMap[cuenta.id] = item
      @items.prepend item.el

  removeMovimiento: (cuenta) =>
    index = @ajustes.indexOf(cuenta)
    @ajustes.splice(index,1)
    @itemToControllerMap[cuenta.id] = null

  updateTotal: =>
    debito = 0
    credito = 0
    for item in @ajustes
      debito  += item.ajuste.Debito
      credito += item.ajuste.Credito
    @lblCredito.html credito.toMoney()
    @lblDebito.html debito.toMoney()
    @balance = credito-debito
    @lblBalance.html @balance.toMoney()

    
  send: (e) =>
    Ajuste.destroyAll()
    @validationErrors.push "Ingrese al menos un ajuste" if @ajustes.length == 0
    @validationErrors.push "El balance del ajuste debe ser 0.00" if @balance != 0
    monto = 0
    tipo = ''
    for item in @ajustes
      item.checkItem() 
      if item.ajuste.Credito != 0
        monto =  item.ajuste.Credito 
        tipo = "Credito"
      else 
        monto = item.ajuste.Debito
        tipo = "Debito"
      Ajuste.create Cuenta: item.ajuste.Cuenta.id , Tipo: tipo , Monto: monto , Descripcion: item.ajuste.Detalle

    data =
      class: Ajuste
      restData: Ajuste.all()

    @log data

    Spine.trigger "show_lightbox" , "insert" , data , @after_send
    

  after_send: =>
    @reset()

  customReset: =>
    for items in @items
      item?.reset()
    @resetBinding()
    
  

module.exports = Ajustes