require('lib/setup')
Spine = require('spine')
Saldo = require("models/socketModels/saldo")
Cliente = require("models/cliente")

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
    @reload()

  reload: ->
    Saldo.ajax().query( { autorizado: false, tipos: "'NC','ND'"  , avoidQueryTimeBased: true} , afterSuccess: @renderPedidos )        

  render: =>
    notas = Saldo.select (item) ->
      return true if !item.Autorizado and (item.Tipo_de_Documento__c = 'NC' or item.Tipo_de_Documento__c = 'ND') and item.Total 

    @srcNotas.html require("views/apps/cuentasPorCobrar/aprobarNota/item")(notas)
    @el.find('.info_popover').popover()


  onSend: (e) =>
    target = $(e.target)
    @saldo = Saldo.find(target.attr("data-id"))
    data =
      class: Saldo
      restRoute: "Saldo"
      restMethod: "POST"
      restData: id :  @saldo.id

    Spine.trigger "show_lightbox" , "rest" , data , @onAprobarSuccess

  onAprobarSuccess: =>
    cliente = Cliente.find @saldo.Cliente
    Spine.socketManager.pushToFeed( "Aprobe una Nota de Credito de #{cliente.Name}")

    Spine.throttle ->
      Spine.socketManager.pushToProfile("Ejecutivo Credito" , "He aprobado algunas Notas de Credito")
    , 35000
    
    @saldo.Autorizado= true;
    @saldo.save()
    @render()

  reset: ->
    Saldo.unbind "query_success" , @render
    @release()
    @navigate "/apps"

module.exports = AprobarNota