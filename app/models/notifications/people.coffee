Spine = require('spine')

class People extends Spine.Model
  @configure 'People' , "image" , "title" ,  "text" , "date"

  @createFromChannel: (members) ->
    
    
    for people in People.all()
      p = members[people.id]
      people.destroy() if !p
    
    for index,member of members._members_map
      people = People.exists member.id
      if !people
        People.create
          date    :   new Date()
          image   :   member.photo
          text    :   ""
          title   :   member.name
          id      :   member.id
          online  :   true

    console.log People.all()

module.exports = People