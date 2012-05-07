Spine = require('spine')


class ErrorManager
  
  @logError: (error) ->
    if error.indexOf("Script error") == -1
      Spine.trigger "show_lightbox","showError" , error: error
  
module.exports = ErrorManager