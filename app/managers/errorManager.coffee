Spine = require('spine')


class ErrorManager
  
  @logError: (error) ->
    if error.indexOf("Error de Validacion") == -1 and error.indexOf("Script error") == -1
      Spine.trigger "show_lightbox","showError" , error: error
  
module.exports = ErrorManager