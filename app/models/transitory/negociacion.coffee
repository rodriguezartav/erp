Spine = require('spine')

class Negociacion extends Spine.Model
  @configure 'Negociacion', "Familia" ,  "SubFamilia" , "Descuento" 

  @createFromProducto: (producto ) ->
    negociacion = Negociacion.create
      Familia: producto.Familiar
      SubFamilia: producto.SubFamilia
      Descuento: 0

  @createFromCliente: (cliente) ->
    negociaciones = []
    try
      negociacion = cliente.Negociacion
      negociacion = $('<div/>').html(negociacion).text();
      negociaciones = JSON.parse(negociacion)
    catch error
      negociaciones = []
      
    for negociacion in negociaciones
      Negociacion.create
        Familia: negociacion.Familia
        SubFamilia: negociacion.SubFamilia
        Descuento: negociacion.Descuento
    

  @fromJson: (json) ->
    negociacion = JSON.parse json
    for item in items
      Negociacion.create item
    
  @toJson: ->
    JSON.stringify Negociacion.all()

  @createFromProducto: (producto) ->
    negociacion = Negociacion.create
      Familia: producto.Familia
      SubFamilia: producto.SubFamilia
      Descuento: 0
    negociacion

module.exports = Negociacion