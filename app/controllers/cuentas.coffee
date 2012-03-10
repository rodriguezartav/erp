require('lib/setup')
Spine = require('spine')

Clientes = require("controllers/clientes")
Main = require("controllers/main")

class Cuentas extends Spine.Controller
  className: "row"
  
  constructor: ->
    super
    clientes = new Clientes
    main  = new Main
    
    @append clientes,main

module.exports = Cuentas
