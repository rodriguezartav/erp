Spine = require('spine')


class ErrorManager
  
  @logError: (error) ->
    console.log error
    if error.indexOf("Error de Validacion") == -1
      Spine.trigger "show_lightbox","showError" , error: error
  
module.exports = ErrorManager