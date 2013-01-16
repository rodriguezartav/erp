Spine = require('spine')

class Proveedor extends Spine.Model
  @configure 'Proveedor', 'Name','Plazo' , 'CuentaCliente' , 'Cedula' , "TipoCedula" , "Moneda", "CategoriaGasto"

  @extend Spine.Model.SalesforceModel
  @extend Spine.Model.SalesforceAjax if typeof window != 'undefined'
  @extend Spine.Model.SelectableModel if typeof window != 'undefined'
  @extend Spine.Model.SocketModel

  tipoCedulaNumeric: =>
    if @TipoCedula == "Persona Fisica Nacional" then return 0
    if @TipoCedula == "Persona Fisica Residente" then return 1
    if @TipoCedula == "Persona Juridica" then return 2
    if @TipoCedula == "Gobierno" then return 3
    if @TipoCedula == "Institucion Autonoma" then return 4
    return -1

  monedaNumeric: =>
    if @Moneda == "Colones" then return 1
    if @Moneda == "Dolares" then return 2    

module.exports = Proveedor