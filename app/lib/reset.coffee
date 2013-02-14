Spine = require('spine')

Spine.reset= =>
  for index , item of localStorage
    localStorage.removeItem(index)
    location.reload();
