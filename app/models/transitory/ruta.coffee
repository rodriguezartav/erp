Spine = require('spine')

class Ruta extends Spine.Model
  @configure "Ruta" , "Fecha" , "Camion" , "Chofer" ,  "Documentos"
 
  @extend Spine.Model.TransitoryModel

module.exports = Ruta

