require('lib/setup')
Spine = require('spine')
Documento = require("models/documento")
Cliente = require("models/cliente")
Producto = require("models/producto")
PedidoPreparado = require("models/socketModels/pedidoPreparado")
Saldo = require("models/socketModels/saldo")
SinglePedido = require("apps/pedidos/singlePedidos")    

Pedido = require("models/transitory/pedido")
PedidoItem = require("models/transitory/pedidoItem")

class PedidosLiveCycle extends Spine.Controller
  className: "row-fluid"

  @departamento = "Pedidos"
  @label = "Pedidos"
  @icon = "icon-shopping-cart"

  elements:
    ".src_pedidos_guardados" : "src_pedidos_guardados" 
    ".src_pedidos_pendientes" : "src_pedidos_pendientes" 
    ".src_pedidos_archivados" : "src_pedidos_archivados"
    ".src_pedidos_aprobados" : "src_pedidos_aprobados"
    ".src_pedidos_facturados" : "src_pedidos_facturados"
    ".src_pedidos_anulados" : "src_pedidos_anulados"
    ".src_pedidos_archivados_detail" : "src_archivados_detail"
    ".src_saldos" : "src_saldos"
    ".src_cliente" : "src_cliente"
    ".src_options" : "src_options"
    ".content" : "content"
    ".txt_observacion" : "txt_observacion"
    ".txt_observacion_guardado" : "txtObservacionGuardado"
    ".pedido_detail_info" : "pedido_detail_info"
    ".src_pedidos_list" : "src_pedidos_list"
    ".view" : "view"
    ".print" : "print"
    ".txtObservacionGuardados" : "txtObservacionGuardados"

  events:
    "click .aprobar"  : "onActionClick"
    "click .archivar" : "onActionClick"
    "click .reload" : "reload"
    "click .btn_create" : "onCreate"
    "click .btn_send" : "onBtnSend"
    "click .btn_send_espera" : "onBtnSendEspera"

    "click .btn_borrar" : "onBtnBorrar"
    "click .btn_print" : "onPrint"
    "click .btn_print_blank" : "onPrintBlank"
    "click .btn_print_proforma" : "onPrintProforma"
    "click textarea" : "onTextAreaClick"

  constructor: ->
    super
    @html require("views/apps/pedidos/pedidosLiveCycle/layout")(PedidosLiveCycle)
    @renderPedidos()
    PedidoPreparado.bind "push_success" , @renderPedidos
    PedidoPreparado.bind "refresh" , @renderPedidos

  reload: ->
    PedidoPreparado.destroyAll()
    @renderPedidos()
    PedidoPreparado.ajax().query( )    

  renderPedidos: =>
    aprobados= []
    archivados = []
    pendientes = []
    facturados = []
    groups = []
    guardados = Pedido.all()
    archivadosList = PedidoPreparado.findAllByAttribute "Estado" , "Archivado"

    groups = PedidoPreparado.group_by_codigoexterno(PedidoPreparado.all())
    for group in groups
      if group.Estado == 'Pendiente'
        saldos = Saldo.select (item) ->
          return true if item.Cliente == group.Cliente and item.Saldo != 0
          return false

        saldos = saldos.sort (a,b) ->
          return b.PlazoActual - a.PlazoActual

        pendientes.push group: group, saldos: saldos
      else
        aprobados.push group if group.Estado == "Aprobado"
        facturados.push group if group.Estado == "Facturado"
        archivados.push group if group.Estado == "Archivado"
      
    archivadosMapFamilias = {}
    archivadosList.sort (a,b) =>
      return b.Cantidad - a.Cantidad
    for item in archivadosList
      producto = Producto.find item.Producto
      familiaAmount = archivadosMapFamilias[producto.Familia] || cantidad: 0, clientes: [] , familia: producto.Familia
      familiaAmount.cantidad += item.Cantidad
      familiaAmount.clientes.push item.Cliente if familiaAmount.clientes.indexOf(item.Cliente) == -1
      archivadosMapFamilias[producto.Familia] = familiaAmount

    @src_pedidos_list.html "<li><h5>No hay pedidos en la lista</h5></li>"
    @src_pedidos_guardados.html require("views/apps/pedidos/pedidosLiveCycle/smartItemGuardado")( guardados ) if guardados.length > 0
    @src_pedidos_pendientes.html require("views/apps/pedidos/pedidosLiveCycle/smartItemPendiente")( pendientes ) if pendientes.length > 0
    @src_pedidos_aprobados.html require("views/apps/pedidos/pedidosLiveCycle/smartItemAprobado")( aprobados) if aprobados.length > 0
    @src_pedidos_archivados.html require("views/apps/pedidos/pedidosLiveCycle/smartItemArchivado")( archivados ) if archivados.length > 0
    @src_pedidos_facturados.html require("views/apps/pedidos/pedidosLiveCycle/smartItemFacturado")( facturados ) if facturados.length > 0

    @src_archivados_detail.html require("views/apps/pedidos/pedidosLiveCycle/item_archivado_detail")(archivadosMapFamilias)
    
    setTimeout ( ->
      $('.archivoDetail').popover()
    ), 1000

  onCreate: (e) =>
    target = $(e.target)
    target = target.parent() until target.data("type")
    type = target.data "type"
    create = $("<div class='create'></div>")
    @el.prepend create
    @singlePedido.reset() if @singlePedido
    @singlePedido = new SinglePedido 
      el: create
      isContado: if type == "contado" then true else false
      onSuccess: =>
        @renderPedidos()
        @onCreateComplete()
      onCancel: @onCreateComplete

  onCreateComplete: =>
    @view.show()

  onBtnSend: (e) =>
    target = $(e.target)
    target = target.parent() until target.hasClass "btn"
    id = target.data "id"
    @pedido = Pedido.find id
    pedidos = PedidoItem.salesforceFormat( PedidoItem.itemsInPedido(@pedido)  , false) 

    data =
      class: PedidoItem
      restRoute: "Oportunidad"
      restMethod: "POST"
      restData: oportunidades: pedidos 

    Spine.trigger "show_lightbox" , "rest" , data , @after_send

  onBtnSendEspera: (e) =>
    target = $(e.target)
    target = target.parent() until target.hasClass "btn"
    id = target.data "id"
    @pedido = Pedido.find id
    pedidos = PedidoItem.itemsInPedido(@pedido)
    li = target.parents("li")
    observacion = li.prev().find("textarea").val() || ""

    for pedido in pedidos
      pedido.Estado = "Archivado"
      pedido.DetalleAprobacion = observacion
      pedido.save()
    pedidos = PedidoItem.salesforceFormat(  pedidos , false) 

    data =
      class: PedidoItem
      restRoute: "Oportunidad"
      restMethod: "POST"
      restData: oportunidades: pedidos 

    Spine.trigger "show_lightbox" , "rest" , data , @after_send

  after_send: =>
    @pedido.destroy()
    @renderPedidos()

  onBtnBorrar: (e) =>
    target = $(e.target)
    target = target.parent() until target.hasClass "btn"
    id = target.data "id"    
    pedido = Pedido.find id
    pedido.destroy()
    @renderPedidos()

  onBtnDeleteAll: =>
    Pedido.destroyAll()
    @renderPedidos()

  onTextAreaClick: (e) =>
    target = $(e.target)
    target.val target.val().trim()
    target.select()
    return false;

  onArchivadosClick: (e) =>
    target = $(e.target)
    target = target.parent() until target.hasClass "archivadoTab"
    @tabPane.hide()
    div = target.data "div"
    divEl = @el.find "##{div}"
    divEl.show()


  onActionClick: (e) =>
    target = $(e.target)
    target = target.parent() until target.hasClass "btn"
    li = target.parents("li")
    observacion = li.prev().find("textarea").val() || ""
    
    referencia = target.attr "data-referencia"
    codigoexterno = target.attr "data-codigoexterno"
    return false if !codigoexterno

    @newEstado = parseInt( target.attr("data-newEstado") )    
    @pedidos = PedidoPreparado.findAllByAttribute "CodigoExterno" , codigoexterno
    @cliente = target.attr "data-cliente"

    for pedido in @pedidos
      pedido.DetalleAprobacion = observacion
      pedido.save()
      
    data =
      class: PedidoPreparado
      restRoute: "Oportunidad"
      restMethod: "PUT"
      restData: codigoexterno: codigoexterno , observacion: observacion, newEstado: @newEstado

    Spine.trigger "show_lightbox" , "rest" , data , @aprobarSuccess
    return false;

  aprobarSuccess: (success,results) =>
    @notify()
    showInvoice = false
    for pedido in @pedidos
      if @newEstado == -2
        pedido.Estado = "Borrardo"
      else if @newEstado == -1
        pedido.Estado = "Perdido"
      else if @newEstado == 0
        pedido.Estado = "Archivado"
      else if @newEstado == 1
        pedido.Estado = "Pendiente"
      else if @newEstado == 2
        pedido.Estado = "Aprobado"
      else if @newEstado == 3        
        pedido.Estado = "Facturado"
        showInvoice=true
      pedido.save()

    @newEstado = null
    @pedidos = null
    @cliente = null
    @renderPedidos()

    #url = Spine.session.instance_url + "/apex/invoice_topdf?Documento__c_id=" + results?.response
    #window.open(url) if showInvoice
    @onShowInvoice(success,results) if showInvoice

  onPrint: (e) =>
    target = $(e.target)
    target = target.parent() until target.hasClass "btn"
    @showInvoice(target.data "documento")
    return false

  onPrintBlank: (e) =>
    @print.html require("views/apps/pedidos/pedidosLiveCycle/printBlank")()
    first = @print.find ".copy"
    first.removeClass "copy"
    first.addClass "original"
    window.print()

  showInvoice: (documentoId) =>
    data =
      class: PedidoPreparado
      restRoute: "Print"
      restMethod: "POST"
      restData: documentoId: documentoId

    Spine.trigger "show_lightbox" , "rest" , data , @onShowInvoice
    return false;

  onShowInvoice: (success , response) =>
    Spine.trigger "hide_lightbox"
    @print.html require("views/apps/pedidos/pedidosLiveCycle/print")(response)
    first = @print.find ".copy"
    first.removeClass "copy"
    first.addClass "original"
    @print.append require("views/apps/pedidos/pedidosLiveCycle/print")(response)
    @print.append require("views/apps/pedidos/pedidosLiveCycle/print")(response) if response.documento.Plazo__c > 0
    window.print()

  onPrintProforma: (e) =>
    target = $(e.target)
    target = target.parent() until target.hasClass "btn"
    codigoexterno = target.attr "data-codigoexterno"

    pedidos = PedidoPreparado.findAllByAttribute "CodigoExterno" , codigoexterno

    pedido = PedidoPreparado.group_by_codigoexterno pedidos

    @print.html require("views/apps/pedidos/pedidosLiveCycle/printProforma")(pedido: pedido[0], items: pedidos)
    window.print()

  notify: =>
    #cliente = Cliente.find @cliente
    #verb = if @aprobar == 2 then "Aprobe" else "Archive"
    #Spine.socketManager.pushToFeed("#{verb} un pedido de #{cliente.Name}") 

    #Spine.throttle ->
     # Spine.socketManager.pushToProfile("Ejecutivo Ventas" , "#{verb} varios pedidos, pueden proceder a revisarlos.")
    #, 15000

  reset: ->
    @pedido = null
    PedidoPreparado.unbind "push_success" , @renderPedidos
    PedidoPreparado.unbind "refresh" , @renderPedidos
    @singlePedido.reset() if @singlePedido
    @el.find('.popable').popover("hide")
    $('.popover').hide()
    @release()
    @navigate "/apps"

module.exports = PedidosLiveCycle