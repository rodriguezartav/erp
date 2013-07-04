Spine = require('spine')

class Contacto extends Spine.Model
  @configure 'Contacto', "Nombre" ,  "Puesto" , "Email"  , "Celular"


  @createFromCliente: (cliente) ->
    contactos = []
    try
      contacto = cliente.Contacto
      contacto = $('<div/>').html(contacto).text();
      contactos = JSON.parse(negociacion)
    catch error
      contactos = []
      
    for contacto in contactos
      Contacto.create
        Nombre: contacto.Nombre
        Puesto: negociacion.Puesto
        Email: negociacion.Email
        Celular: negociacion.Celular
    contactos

  @fromJson: (json) ->
    return false if !json
    contactos = JSON.parse json
    for item in contactos
      Contacto.create item
    
  @toJson: ->
    JSON.stringify Contacto.all()

module.exports = Contacto