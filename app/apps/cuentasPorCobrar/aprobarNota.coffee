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
    Saldo.bind "push_success" , @render
    @render()

  reload: ->
    Saldo.query({ autorizado: false, tipos: "'NC','ND'" } , false)    

  render: =>
    notas = Saldo.select (item) ->
      return true if !item.Autorizado and (item.Tipo_de_Documento__c = 'NC' or item.Tipo_de_Documento__c = 'ND') 

    @srcNotas.html require("views/apps/cuentasPorCobrar/aprobarNota/item")(notas)
    @el.find('.info_popover').popover()


  onSend: (e) =>
    target = $(e.target)
    @saldo = Saldo.find(target.attr("data-id"))
    data =
      class: Saldo
      restRoute: "Saldo"
      restMethod: "POST"
      restData: JSON.stringify( { "id" :  @saldo.id } )

    Spine.trigger "show_lightbox" , "rest" , data , @onAprobarSuccess

  onAprobarSuccess: =>
    @saldo.Autorizado= true;
    @saldo.save()
    @render()

  reset: ->
    Saldo.unbind "query_success" , @render
    @release()
    @navigate "/apps"

module.exports = AprobarNota