require('lib/setup')
Spine = require('spine')
Documento = require("models/documento")
Cliente = require("models/cliente")
Clientes = require("controllers/clientes")


class EstadoCuentaCliente extends Spine.Controller
  @departamento = "Credito y Cobro"
  @label = "Estado de Cuenta"
  
  className: "row"

  events:
    "click .print" : "print"
    "click .cancel" : "reset"

  elements: 
    ".src_cliente" : "src_cliente"
    ".src_documentos" : "src_documentos"
    ".loader" : "loader"

  constructor: ->
    super
    @html require("views/apps/procesos/estadoCuenteCliente/layout")(EstadoCuentaCliente)
    Documento.bind "query_success" , @renderDocumentos
    Cliente.reset_current()
    @clientes = new Clientes(el: @src_cliente)
    Cliente.bind 'current_set' , (cliente) =>
      Documento.query { cliente: cliente,saldo: true }
  
  renderDocumentos: =>
    @src_documentos.html require("views/apps/procesos/estadoCuenteCliente/documento")(Documento.all())

  print: (e) =>
    target = $(e.target)
    id = target.attr "data-id"
    doc = Documento.find(id)
    @currentHtml = @el.html()
    @render(doc)
    
  render: (doc) =>
    #layout = require("views/apps/procesos/documentosImpresion/docs/layout")(doc)
    #jLayout = $(layout)
    #jLayout.find(".body").html 
    #jLayout.find(".movimientos").html require("views/apps/procesos/documentosImpresion/docs/movimientos/#{doc.Tipo_de_Documento}")(doc)
    #@log jLayout
    @html require("views/apps/procesos/documentosImpresion/docs/" + doc.Tipo_de_Documento)(doc)

  reset: =>
    @release()
    Documento.unbind "query_success" , @renderDocumentos
    @navigate "/apps"
    


module.exports = EstadoCuentaCliente