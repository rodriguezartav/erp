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
    ".section_standby" : "sectionStandBy"
    ".section_digitados" : "sectionDigitados"
    ".section_entregados" : "sectionEntregados"
    ".section_contabilizados" : "sectionContabilizados"
    ".section_aplicados" : "sectionAplicados"
    ".section_depositados" : "sectionDepositados"
    ".txt_search" : "txt_search"
    ".print"    : "print"

  events:
    "click .cancel"    :  "reset"
    "click .item" : "onItemClick"
    "click .btn_action"    :  "onAction"
    "click .btn_bulk_action" : "onBulkAction"
    "click .reload"    :  "reload"
    "click .userItem"  :  "onUserClick"

  setVariables: =>
    @recibosStandby =[]    
    @recibosDigitados = []
    @recibosEntregados  = []
    @recibosAplicados = []
    @recibosContabilizados = []
    @recibosDepositados = []
    
  constructor: ->
    super
    @html require("views/apps/cuentasPorCobrar/reciboLivecycle/layout")(ReciboLivecycle)
    Pago.bind "query_success" , @render
    @setVariables()
    @reload()

  reload: =>
    @sections.empty()
    search = if @txt_search.val().length > 0 then @txt_search.val() else null
    @txt_search.val ""
    Pago.deleteAll()
    Pago.ajax().query( { livecycle: true  , search: search } , afterSuccess: @render ) 
    @filterByUserId = null

  render: =>
    users=[]
    usersId = []
    @recibosStandby =[]
    @recibosDigitados = []
    @recibosEntregados = []
    @recibosContabilizados = []
    @recibosAplicados = []
    @recibosDepositados = []

    pagos = Pago.select (item) =>
      return true if !@filterByUserId
      return true if item.Custodio and item.Custodio == @filterByUserId
      return false

    for pago in pagos
      if           pago.EstadoNumerico == 0                   then @recibosStandby.push(pago)
      else if      pago.EstadoNumerico == 1                   then @recibosDigitados.push(pago)
      else if      pago.EstadoNumerico == 2                   then @recibosEntregados.push(pago)
      else if      pago.EstadoNumerico == 3                   then @recibosContabilizados.push(pago)
      else if      pago.EstadoNumerico == 4                   then @recibosAplicados.push(pago)
      else if      pago.EstadoNumerico == 5                   then @recibosDepositados.push(pago)

      if pago.Custodio and usersId.indexOf(pago.Custodio) == -1
        usersId.push pago.Custodio 
        users.push User.find pago.Custodio 

    standByAgrupados = Pago.group_by_recibo(@recibosStandby)
    digitadosAgrupados = Pago.group_by_recibo(@recibosDigitados)
    entregadosAgrupados = Pago.group_by_recibo(@recibosEntregados)
    contabilizadosAgrupados = Pago.group_by_recibo(@recibosContabilizados)
    aplicadosAgrupados = Pago.group_by_recibo(@recibosAplicados)
    depositadosAgrupados = Pago.group_by_recibo(@recibosDepositados)

    @sectionStandBy.html require("views/apps/cuentasPorCobrar/reciboLivecycle/itemStandby")(standByAgrupados )
    @sectionDigitados.html require("views/apps/cuentasPorCobrar/reciboLivecycle/sectionDigitados")(pagos: digitadosAgrupados )
    #@sectionEntregados.html require("views/apps/cuentasPorCobrar/reciboLivecycle/sectionEntregados")(pagos: entregadosAgrupados )  
    @sectionContabilizados.html require("views/apps/cuentasPorCobrar/reciboLivecycle/itemContabilizado")( contabilizadosAgrupados )
    #@sectionAplicados.html require("views/apps/cuentasPorCobrar/reciboLivecycle/sectionAplicados")( pagos: aplicadosAgrupados )  
    #@sectionDepositados.html require("views/apps/cuentasPorCobrar/reciboLivecycle/itemDepositado")( depositadosAgrupados )
    @list_users.html require("views/apps/cuentasPorCobrar/reciboLivecycle/user")(users)

  onUserClick: (e) =>
    target = $(e.target)
    parent = target.parent()

    if parent.hasClass "active"
      $(".userList>li").addClass "active"
      parent.removeClass "active"
      @filterByUserId = target.data "id"
    else
      parent.addClass "active"
      @filterByUserId = null

    @render()

  onItemClick: (e) =>
    target = $(e.target)
    target = target.parent() until target.hasClass "item"
    details = target.find(".details")
    status = details.is(":visible")
    @el.find(".details").hide()
    target.find(".details").show() if !status

  onAction: (e) =>
    target = $(e.target)
    action = target.data "action"
    recibo = target.data "recibo"
    ids = []
    ids.push recibo.id for recibo in Pago.findAllByAttribute("Recibo","#{recibo}")
    data =
      class: Pago
      restRoute: "Pago"
      restMethod: "PUT"
      restData: ids: ids , action: action
    Spine.trigger "show_lightbox" , "rest" , data , @reload
   
  onBulkAction: (e) =>
    target = $(e.target)
    action = target.data "action"
    ref = target.data "ref"
    
    ids = []
    ids.push recibo.id for recibo in @["recibos#{ref}"]
    data =
      class: Pago
      restRoute: "Pago"
      restMethod: "PUT"
      restData: ids: ids , action: action
    
    Spine.trigger "show_lightbox" , "rest" , data , =>
      return setTimeout(@printEntrega , 2000 ) if action == 3
      #return setTimeout(@printDeposito , 2000 ) if action == 5
      return @reload()
      
  printEntrega: =>
    @print.html @sectionDigitados.html()
    @print.append '<br/><br/><hr/><br/><br/>'
    @print.append @sectionDigitados.html()
    window.print()
    @reload()

  printDeposito: =>
    html = @sectionAplicados.html()
    @print.html require("views/apps/cuentasPorCobrar/reciboLivecycle/printDeposito")(html)
    @print.append require("views/apps/cuentasPorCobrar/reciboLivecycle/printDeposito")(html)
    window.print()
    @reload()

  onRetener: (e) =>
    target = $(e.target)
    ids = [ target.data "id" ]
    data =
      class: Pago
      restRoute: "Pago"
      restMethod: "PUT"
      restData: ids: ids , action: 1
    Spine.trigger "show_lightbox" , "rest" , data , @reload

  reset: ->
    @setVariables()
    Pago.unbind "query_success" , @render
    @release()
    @navigate "/apps"

module.exports = ReciboLivecycle