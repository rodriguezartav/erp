require('lib/setup')
Spine = require('spine')
Saldo = require("models/socketModels/saldo")

class AprobarNota extends Spine.Controller
  className: "row-fluid"

  @departamento = "Credito y Cobro"
  @label = "Aprobacion de Notas"
  @icon = "icon-ok-sign"

  elements:
    ".srcNotas" : "srcNotas" 
    ".error"      : "error"
    ".lblTotal"  : "lblTotal"
    ".saldo"      : "saldos"

  events:
    "click .cancel"   : "reset"
    "click .aprobar"     : "onSend"
    "click .reload"   : "reload"

  constructor: ->
    super
    @html require("views/apps/cuentasPorCobrar/aprobarNota/layout")(AprobarNota)
    Saldo.bind "query_success" , @render
    @render()

  reload: ->
    Saldo.query({ autorizado: true, tipos: "'NC','ND'" })    

  render: =>
    notas = Saldo.select (item) ->
      return if (item.Tipo_de_Documento == 'NC' or item.Tipo_de_Documento == 'ND') and item.Saldo !=0 then true else false

    @srcNotas.html require("views/apps/cuentasPorCobrar/aprobarNota/item")(notas)
    @el.find('.info_popover').popover()

      
  onSend: (e) =>
    target = $(e.target)
    @saldo = Saldo.find(target.attr("data-id"))
    @saldo.Autorizado= true;
    @saldo.save()    
    saldoSf = Saldo.toSalesforce(@saldo)
    Saldo.rest 
    data =
      class: Saldo
      restRoute: "Documento"
      restMethod: "PUT"
      restData: JSON.stringify( { "saldos" :  [ saldoSf ] } )

    Spine.trigger "show_lightbox" , "update" , data , @onAprobarSuccess


  onAprobarSuccess: =>
    @saldo.destroy()
    @render()

  reset: ->
    Saldo.unbind "query_success" , @render
    @release()
    @navigate "/apps"

module.exports = AprobarNota