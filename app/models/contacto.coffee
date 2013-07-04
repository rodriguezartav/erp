Spine = require('spine')

class Contacto extends Spine.Model
  @configure 'Contacto', "Nombre" ,  "Puesto" , "Email"  , "Celular"


  @createFromCliente: (cliente) ->
    contactos = []
    try
      contactoStr = cliente.Contactos
      contactoStr = $('<div/>').html(contactoStr).text();
      contactos = JSON.parse(contactoStr)
    catch error
      contactos = []
      
    for contacto in contactos
      Contacto.create
        Nombre: contacto.Nombre
        Puesto: contacto.Puesto
        Email: contacto.Email
        Celular: contacto.Celular
    contactos

  @fromJson: (json) ->
    return false if !json
    contactos = JSON.parse json
    for item in contactos
      Contacto.create item
    
  @toJson: ->
    JSON.stringify Contacto.all()

module.exports = Contacto