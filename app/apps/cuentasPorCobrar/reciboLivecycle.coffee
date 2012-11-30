require('lib/setup')
Spine = require('spine')
Pago = require("models/pago")
Cliente = require("models/cliente")
User = require("models/user")

class ReciboLivecycle extends Spine.Controller
  className: "row-fluid"

  @departamento = "Credito y Cobro"
  @label = "Administracion de Recibos"
  @icon = "icon-ok-sign"

  elements:
    ".list_users" : "list_users"
    ".sections"   : "sections"

  events:
    "click .cancel"    :  "reset"
    "click .btn_entregar"  : "onGenerarEntrega"
    "click .item" : "onItemClick"
  #  "click .send"      :  "onSend"
  #  "click .incluir"   :  "onIncluir"
  #  "click .borrar"    :  "onBorrar"
   # "click .reload"    :  "reload"
  #  "click .userItem"  :  "onUserClick"

  constructor: ->
    super
    @html require("views/apps/cuentasPorCobrar/reciboLivecycle/layout")(ReciboLivecycle)
    Pago.bind "query_success" , @render
    @recibosPendientes = []
    @recibosAprobados = []
    @reload()
    

  reload: ->
    @el.find(".list").empty()
    Pago.ajax().query( { aprobado: false  } , afterSuccess: @render ) 
    @filterByUserId = null
    
  render: =>
    users=[]
    usersId = []
    @recibosPendientes =[]
    @recibosAprobados = []
    pagos = Pago.select (item) =>
      return true if !@filterByUserId
      return true if item.CreatedByid and item.CreatedByid == @filterByUserId
      return false

    for pago in pagos
      if pago.Aprobado == false then @recibosPendientes.push(pago) else @recibosAprobados.push(pago)
      if usersId.indexOf(pago.CreatedByid) == -1
        usersId.push pago.CreatedByid 
        users.push User.find pago.CreatedByid 

    pendientesAgrupados = Pago.group_by_recibo(@recibosPendientes)
    aprobadosAgrupados = Pago.group_by_recibo(@recibosAprobados)

    @sections.html require("views/apps/cuentasPorCobrar/reciboLivecycle/sectionPendientes")(pagos: pendientesAgrupados)
    @sections.append require("views/apps/cuentasPorCobrar/reciboLivecycle/sectionPendientes")(pagos: aprobadosAgrupados)

    @list_users.html require("views/apps/cuentasPorCobrar/reciboLivecycle/user")(users)

  onItemClick: (e) =>
    target = $(e.target)
    target = target.parent() until target.hasClass "item"
    details = target.find(".details")
    status = details.is(":visible")
    @el.find(".details").hide()
    target.find(".details").show() if !status

  onGenerarEntrega: (e) ->
    target = $(e.target)
    section = target.parents ".section"
    @el.find(".section").hide()
    section.show()
    section.removeClass "span4"
    window.print()


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
      restData: ids: ids , action: 1

    Spine.trigger "show_lightbox" , "rest" , data , @onAprobarSuccess

  onAprobarSuccess: =>
    @recibosIncluidos = []
    Spine.socketManager.pushToFeed( "Aprobe varios recibos")
    @reload()

  onBorrar: (e) =>
    ids = []
    recibo = target.attr "data-recibo"
    pagos = Pago.findAllByAttribute "Recibo" , recibo
    ids.push pago.id for pago in pagos

    data =
      class: Pago
      restRoute: "Pago"
      restMethod: "PUT"
      restData: ids: ids , action: -1

    Spine.trigger "show_lightbox" , "rest" , data , @onAprobarSuccess

  onBorrarSuccess: =>
    @recibosIncluidos = []
    Spine.socketManager.pushToFeed( "Borre varios recibos")
    @reload()

  reset: ->
    Pago.unbind "query_success" , @render
    @release()
    @navigate "/apps"

module.exports = ReciboLivecycle