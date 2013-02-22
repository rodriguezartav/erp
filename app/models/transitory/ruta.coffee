Spine = require('spine')

class Ruta extends Spine.Model
  @configure "Ruta" , "Fecha" , "Camion" , "Chofer" ,  "Documentos" , "Name" , "Enviado"
 
  @extend Spine.Model.TransitoryModel

  toString: =>
    return "#{@Fecha} #{@Camion} #{@Chofer}"

  createFromAttributes: (attr) =>
    name = "#{attr.Fecha} #{attr.Camion} #{attr.Chofer}"
    test = Ruta.findByAttribute "Name" , name
    if test
      test.Name += "*"
    ruta = Ruta.create Name: name , Fecha: attr.Fecha , Chofer: attr.Chofer, Camion: attr.Camion, Documentos: [] , Enviado: false
    return ruta


  @tempFromString: (string) =>
    parts = string.split " "
    return Fecha: parts[0] , Camion: parts[1] , Chofer: parts[2] , Documentos: []

module.exports = Ruta

