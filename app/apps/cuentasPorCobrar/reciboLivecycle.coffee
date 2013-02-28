require('lib/setup')
Spine = require('spine')
Pago = require("models/pago")
Cliente = require("models/cliente")
User = require("models/user")
LocalPago = require("models/transitory/pago")
LocalPagoItem = require("models/transitory/pagoItem")
SinglePago = require("apps/cuentasPorCobrar/singlePago")

class ReciboLivecycle extends Spine.Controller
  className: "row-fluid"

  @departamento = "Credito y Cobro"
  @label = "Recibos"
  @icon = "icon-inbox"

  elements:
    ".sections"   : "sections"
    ".section_standby" : "sectionStandBy"
    ".section_digitados" : "sectionDigitados"
    ".section_aplicados" : "sectionAplicados"
    ".txt_search"  : "txt_search"
    ".list_search" : "listSearch"
    ".list_users" : "listUsers"
    ".view"        :  "view"
    ".print"       : "print"

  events:
    "click .item" : "onItemClick"
    "click .btn_action"    :  "onAction"
    "click .btn_bulk_action" : "onBulkAction"
    "click .reload"    :  "reload"
    "click .userItem"  :  "onUserClick"
    "click .btn_selected" : "onBtnSelectedClick"
    "click .btn_aplicar"  : "onBtnAplicar"
    "click .btn_create" : "onCreate"
    "click .btn_borrar" : "onBorrar"
    "click .btn_enviar" : "onEnviar"
    "click .btn_print_entrega" : "onPrintEntrega"
    "click .btn_print"  : "onPrint"

  setVariables: =>
    @recibosStandby =[]    
    @recibosDigitados = []
    @recibosEntregados  = []
    @recibosAplicados = []
    @recibosContabilizados = []
    @recibosDepositados = []
    @recibosParaAplicar = []
    
  constructor: ->
    super
    @html require("views/apps/cuentasPorCobrar/reciboLivecycle/layout")(ReciboLivecycle)
    @setVariables()
    @reload()

  reload: =>
    @sections.empty()
    @renderGuardados()
    @filterByUserId = null
    Pago.deleteAll()    
    return @search() if @txt_search.val().length > 0
    Pago.ajax().query( { livecycle: true  } , afterSuccess: @render ) 

  search: =>
    search = @txt_search.val() 
    @txt_search.val ""
    Pago.ajax().query( { search: search } , afterSuccess: @render ) 


  renderGuardados: =>
    @listSearch.html require("views/apps/cuentasPorCobrar/reciboLivecycle/itemGuardado")(LocalPago.all() )

  render: =>
    users=[]
    usersId = []
    @recibosStandby =[]
    @recibosDigitados = []
    @recibosAplicados = []

    pagos = Pago.select (item) =>
      return true if !@filterByUserId
      return true if item.Custodio and item.Custodio == @filterByUserId
      return false

    for pago in pagos
      if           pago.EstadoNumerico == 0                   then @recibosStandby.push(pago)
      else if      pago.EstadoNumerico == 1                   then @recibosDigitados.push(pago)
      else if      pago.EstadoNumerico == 2 or pago.EstadoNumerico == 4                   then @recibosAplicados.push(pago)

      if pago.Custodio and usersId.indexOf(pago.Custodio) == -1
        usersId.push pago.Custodio 
        users.push User.find pago.Custodio 

    standByAgrupados = Pago.group_by_recibo(@recibosStandby)
    digitadosAgrupados = Pago.group_by_recibo(@recibosDigitados)
    aplicadosAgrupados = Pago.group_by_recibo(@recibosAplicados)

    standByAgrupados = standByAgrupados.sort (a,b) =>
      return new Date(a.Fecha) - new Date(b.Fecha)

    @sectionStandBy.html require("views/apps/cuentasPorCobrar/reciboLivecycle/sectionStandBy")(pagos: standByAgrupados )
    @sectionDigitados.html require("views/apps/cuentasPorCobrar/reciboLivecycle/sectionDigitados")(pagos: digitadosAgrupados )
    @sectionAplicados.html require("views/apps/cuentasPorCobrar/reciboLivecycle/sectionAplicados")(pagos: aplicadosAgrupados )

    @listUsers.html require("views/apps/cuentasPorCobrar/reciboLivecycle/user")(users)

    pickers = @el.find('.txtFecha').datepicker({autoclose: true})
    pickers.on("change",@onStandbyDateChange)
    @renderGuardados()

  onCreate: =>
    create = $("<div class='create'></div>")
    @el.prepend create
    @singlePago.reset() if @singlePago
    @singlePago = new SinglePago 
      el: create
      onSuccess: (reloadPagos) =>
        @renderGuardados()
        @onCreateComplete()
        @reload() if reloadPagos
      onCancel: @onCreateComplete

  onCreateComplete: =>
    @view.show()

  onBorrar: (e) =>
    target = $(e.target)
    id = target.data "id"
    pago = LocalPago.find id
    LocalPagoItem.deleteItemsInPago(pago)
    pago.destroy()
    @renderGuardados()

  onEnviar: (e) =>
    target = $(e.target)
    id = target.data "id"
    @pago = LocalPago.find id

    pagos = LocalPagoItem.itemsInPago(@pago) 

    if pagos.length == 0
      error = "Error del sistema, el pago no tiene lineas asignadas. Intente borrandolo e ingresandolo nuevamente."
      Spine.trigger "show_lightbox" , "showError" , error: error
      throw error

    data =
      class: LocalPagoItem
      restRoute: "Pago"
      restMethod: "POST"
      restData: 
        pagos: LocalPagoItem.salesforceFormat( pagos, false) 

    Spine.trigger "show_lightbox" , "rest" , data , @after_send
    return false;

  after_send: =>
    LocalPagoItem.deleteItemsInPago(@pago)
    @pago.destroy()
    @pago = null
    @reload()

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

  onStandbyDateChange: (e) =>
    target = $(e.target)
    action = Date.parse(target.val())
    recibo = target.data "recibo"
    ids = []
    ids.push recibo.id for recibo in Pago.findAllByAttribute("Recibo","#{recibo}")
    data =
      class: Pago
      restRoute: "Pago"
      restMethod: "PUT"
      restData: ids: ids , action: action
    Spine.trigger "show_lightbox" , "rest" , data , @reload

  onBtnSelectedClick: (e) =>
    target = $(e.target)
    recibo = target.data "recibo"
    selectedClass = "btn-primary paraAplicar"
    if target.hasClass selectedClass
      target.removeClass selectedClass 
      index = @recibosParaAplicar.indexOf recibo
      @recibosParaAplicar.splice index , 1
    else
      target.addClass selectedClass
      @recibosParaAplicar.push recibo
    return false;

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
      @reload()

  onPrintEntrega: =>
    @print.html @sectionDigitados.html()
    @print.append '<br/><br/><hr/><br/><br/>'
    @print.append @sectionDigitados.html()
    window.print()
    @reload()

  onPrint: (e) =>
    target = $(e.target)
    recibo = target.data "recibo"
    pagoid  = target.data "pago-id"
    pago = null
    pagoItems=[]
    
    
    if pagoid
      pago = LocalPago.find pagoid
      pagoItems = LocalPagoItem.itemsInPago(pago)
    else
      recibo = "#{recibo}"
      for pago in Pago.all()
        pagoItems.push pago if pago.Recibo == recibo

      pago = Pago.group_by_recibo(pagoItems)[0]

    @print.html require("views/apps/cuentasPorCobrar/reciboLivecycle/printRecibo")(pago:pago , pagoItems: pagoItems )
    @print.append require("views/apps/cuentasPorCobrar/reciboLivecycle/printRecibo")(pago:pago , pagoItems: pagoItems , copy: true )

    window.print()

  onRetener: (e) =>
    target = $(e.target)
    ids = [ target.data "id" ]
    data =
      class: Pago
      restRoute: "Pago"
      restMethod: "PUT"
      restData: ids: ids , action: 0
    Spine.trigger "show_lightbox" , "rest" , data , @reload

  reset: ->
    @setVariables()
    @singlePago.reset() if @singlePago
    Pago.unbind "query_success" , @render
    @release()
    @navigate "/apps"

module.exports = ReciboLivecycle