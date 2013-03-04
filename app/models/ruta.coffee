Spine = require('spine')

class Ruta extends Spine.Model
  @configure "Ruta" , "Fecha" , "Camion" , "Chofer" ,  "Documentos" , "Name" , "Enviado"
 
  toString: =>
    return @Name

  @updateName: (ruta) =>
    return "#{ruta.Fecha} #{ruta.Camion} #{ruta.Chofer}"

  @findByName: (name) =>
    return @findByAttribute "Name" , name

  @createFromAttributes: (attr) =>
    name = "#{attr.Fecha} #{attr.Camion} #{attr.Chofer}"
    test = Ruta.findByAttribute "Name" , name
    name = test.Name + "*" if test
    ruta = Ruta.create Name: name , Fecha: attr.Fecha , Chofer: attr.Chofer, Camion: attr.Camion, Documentos: [] , Enviado: false
    return ruta

  @tempFromString: (string) =>
    parts =  string.replace("*","").split " "
    fecha =  parts[0]
    camion = parts[1]
    chofer = parts[2]
    return Name: string , Fecha: fecha , Camion: camion , Chofer: chofer , Documentos: []

module.exports = Ruta

