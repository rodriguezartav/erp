Spine = require('spine')

class Ruta extends Spine.Model
  @configure "Ruta" , "Fecha" , "Camion" , "Chofer" ,  "Documentos"
 
  @extend Spine.Model.TransitoryModel

  toString: =>
    return "#{@Fecha} #{@Camion} #{@Chofer}"

  @tempFromString: (string) =>
    parts = string.split " "
    return Fecha: parts[0] , Camion: parts[1] , Chofer: parts[2] , Documentos: []

module.exports = Ruta

