Spine = require('spine')

Registro = require("models/registro")

class VerCierre extends Spine.Controller
  
  className: "row-fluid VerCierre"
  
  @departamento = "Diario"
  @label = "Cierre Contable"
  @icon = "icon-eye-open"

  elements:
    ".departamentos_list"       : "departamentos_list"
    ".viewDate"             : "viewDate"

  events:
    "click .cancel" : "reset"

  setBindings: ->
    Registro.bind 'query_success' , @onRegistroLoaded
 
  preset: ->
    Registro.destroyAll()
    Registro.query( today: true )

  constructor: ->
    super
    @preset()
    @render()
    @setBindings()
   
  render: ->
    @html require("views/apps/vistas/verCierre/layout")(VerCierre)
    @viewDate.val new Date().to_salesforce()
    pickers =  @viewDate.datepicker({autoclose: true})
    pickers.on("change",@onDateChange)

  onDateChange: (e) =>
    target = $(e.target)
    fecha = new Date(target.val())
    console.log fecha.to_salesforce_date()
    Registro.query( fecha: fecha.to_salesforce_date() )

  onRegistroLoaded: =>
    departamentosList = Registro.uniqueDepartamentos()
    content1 = $("<div class='row-fluid'></div>")
    content2 = $("<div class='row-fluid'></div>")
    content3 = $("<div class='row-fluid'></div>")
    content4 = $("<div class='row-fluid'></div>")
    for departamentoName in departamentosList
      registros = Registro.findAllByAttribute "Departamento" , departamentoName
      departamentoGroup = Registro.groupByTipo(registros)
      if departamentoName == 'ventas credito' or departamentoName == 'ventas contado' or departamentoName == 'impuesto ventas'
        content1.append require("views/apps/vistas/verCierre/departamento")(Departamento: departamentoName , Tipos: departamentoGroup)
      else if departamentoName == 'cobro' or departamentoName == "saldos"
        content2.append require("views/apps/vistas/verCierre/departamento")(Departamento: departamentoName , Tipos: departamentoGroup)
      else if departamentoName == 'inventarios valor' or departamentoName == 'inventarios unidad'
        content3.append require("views/apps/vistas/verCierre/departamento")(Departamento: departamentoName , Tipos: departamentoGroup)
      else
        content4.append require("views/apps/vistas/verCierre/departamento")(Departamento: departamentoName , Tipos: departamentoGroup)

    @departamentos_list.html content1
    @departamentos_list.append "<hr/>"
    @departamentos_list.append content2
    @departamentos_list.append "<hr/>"
    @departamentos_list.append content3
    @departamentos_list.append "<hr/>"
    @departamentos_list.append content4
    $('.popable').popover()

  reset: ->
    Registro.destroyAll()
    @navigate "/apps"

module.exports = VerCierre