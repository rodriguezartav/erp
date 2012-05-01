Spine = require('spine')


class ErrorManager
  
  @logError: (error) ->
    if error.indexOf("Error de Validacion") == -1
      Spine.trigger "show_lightbox","showWarning" , error: error
  
module.exports = ErrorManager