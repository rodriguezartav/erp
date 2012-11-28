require('lib/setup')
Spine = require('spine')
Pago = require("models/pago")
Cliente = require("models/cliente")
User = require("models/user")

class AprobarRecibo extends Spine.Controller
  className: "row-fluid"

  @departamento = "Credito y Cobro"
  @label = "Aprobacion de Recibos"
  @icon = "icon-ok-sign"

  elements:
    ".srcRecibos" : "srcRecibos" 
    ".error"      : "error"
    ".lblTotal"  : "lblTotal"
    ".saldo"      : "saldos"
    ".lblCheque"       : "lblCheque"
    ".lblEfectivo"       : "lblEfectivo"
    ".lblNotaCredito"       : "lblNotaCredito"
    ".lblDeposito"       : "lblDeposito"    
    ".userList"  : "userList"

  events:
    "click .cancel"    : "reset"
    "click .send"    : "onSend"
    "click .incluir"  : "onIncluir"
    "click .reload"    : "reload"
    "click .userItem"  : "onUserClick"

  constructor: ->
    super
    @html require("views/apps/cuentasPorCobrar/aprobarRecibo/layout")(AprobarRecibo)
    Pago.bind "query_success" , @render
    @renderUsers()
    @reload()

  reload: ->
    @srcRecibos.empty()
    Pago.ajax().query( { aprobado: false  } , afterSuccess: @render ) 
    @recibosIncluidos = []
    @filterByUserId = null
    
  render: =>
    pagos = Pago.select (item) =>
      return true if !@filterByUserId
      return true if item.CreatedByid and item.CreatedByid == @filterByUserId
      return false

    recibos = Pago.group_by_recibo(pagos)
    @srcRecibos.html require("views/apps/cuentasPorCobrar/aprobarRecibo/item")(recibos)

  renderUsers: =>
    users = User.all()
    @userList.html require("views/apps/cuentasPorCobrar/aprobarRecibo/user")(users)

  onIncluir: (e) =>
    target = $(e.target)
    recibo = target.attr "data-recibo"
    pagos = Pago.findAllByAttribute "Recibo" , recibo

    if target.hasClass "active"
      @recibosIncluidos[pago.id] = null for pago in pagos
      target.removeClass "active"
    else
      @recibosIncluidos[pago.id] =  pago for pago in pagos
      target.addClass "active"

    @updateResults()
    
  onUserClick: (e) =>
    target = $(e.target)
    parent = target.parent()
    @recibosIncluidos= []
    @updateResults()

    if parent.hasClass "active"
      $(".userList>li").addClass "active"
      parent.removeClass "active"
      @filterByUserId = target.data "id"
    else
      parent.addClass "active"
      @filterByUserId = null
    

    @render()
  
  updateResults: =>
    cheque   = 0;
    nota     = 0;
    efectivo = 0;
    deposito = 0;
    
    
    for index,recibo  of @recibosIncluidos
      if recibo != null
        cheque    += recibo.Monto if recibo.FormaPago == "Cheque"
        nota      += recibo.Monto if recibo.FormaPago == "Nota Credito"
        efectivo  += recibo.Monto if recibo.FormaPago == "Efectivo"
        deposito  += recibo.Monto if recibo.FormaPago == "Deposito"

    @lblCheque.html cheque.toMoney()
    @lblDeposito.html deposito.toMoney()
    @lblNotaCredito.html nota.toMoney()
    @lblEfectivo.html efectivo.toMoney()

  onSend: (e) =>
    ids = []
    for index , recibo of @recibosIncluidos
      ids.push recibo.id if recibo and recibo.id

    data =
      class: Pago
      restRoute: "Pago"
      restMethod: "PUT"
      restData: ids: ids

    Spine.trigger "show_lightbox" , "rest" , data , @onAprobarSuccess

  onAprobarSuccess: =>
    @recibosIncluidos = []
    Spine.socketManager.pushToFeed( "Aprobe varios recibos")
    @reload()


  reset: ->
    Pago.unbind "query_success" , @render
    @release()
    @navigate "/apps"

module.exports = AprobarRecibo