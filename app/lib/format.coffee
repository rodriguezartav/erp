
Array::unique = ->
  output = {}
  output[@[key]] = @[key] for key in [0...@length]
  value for key, value of output

Array.prototype.addUniqueItem = (item)  ->
  index = this.indexOf item
  return false if index != -1
  this.push item
  return true

Array.prototype.addUniqueItems = (items)  ->
  for item in items
    index = this.indexOf item
    this.push item if index == -1
  return true;

Array.prototype.removeItem = (item)  ->
  index = this.indexOf item
  return this if index == -1
  this.splice(index,1)
  return this

Array.prototype.removeItems = (items)  ->
  for item in items
    index = this.indexOf item
    this.splice(index,1) if index != -1
  return this

Array.prototype.remove = (from, to)  ->
  rest = this.slice((to || from) + 1 || @length);
  @length = from < 0 ? @length + from : from;
  return @push.apply(@, rest);

Number.prototype.toMoney = (decimals = 2, decimal_separator = ".", thousands_separator = ",") ->
  n = this
  c = if isNaN(decimals) then 2 else Math.abs decimals
  sign = if n < 0 then "-" else ""
  i = parseInt(n = Math.abs(n).toFixed(c)) + ''
  j = if (j = i.length) > 3 then j % 3 else 0
  x = if j then i.substr(0, j) + thousands_separator else ''
  y = i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + thousands_separator)
  z = if c then decimal_separator + Math.abs(n - i).toFixed(c).slice(2) else ''
  sign + x + y + z

Number.prototype.toSmallLabel = ->
  n = this
  i = parseInt(n = Math.abs(n).toFixed(0)) + ''

  if i.length > 6
    return (n / 1000000).toFixed(1) + 'm'
  if i.length > 5
    return (n / 1000000).toFixed(1) + 'm'
  else if i.length > 3
    return (n / 1000).toFixed(0) + 'k'
  return this.toMoney(0)

Number.prototype.toSmallPrice = ->
  n = this
  i = parseInt(n = Math.abs(n).toFixed(0)) + ''

  if i.length > 6
    return n / 1000000 + 'm'
  else if i.length > 5
    return i.substr(0, 3) + "k"
  else if i.length == 5
    return i.substr(0, 2) + "." + i[3] +  "k"
  return this.toMoney(0)

String.replaceAll = (txt, replace, with_this) ->
  return txt.replace(new RegExp(replace, 'g'),with_this)


String.prototype.capitalize = -> 
  str = this.toLowerCase()
  str = str.replace(', s.a.','')
  str = str.replace('s.a.','')
  return str.replace( /(^|\s)([a-z])/g , (m,p1,p2) -> return p1+p2.toUpperCase() )


String.prototype.getWeek = ->
  date = new Date(Date.parse(this))
  onejan = new Date(date.getFullYear(),0,1);
  return Math.ceil((((date - onejan) / 86400000) + onejan.getDay()+1)/7);


String.prototype.toMMMDate = ->
  date = new Date(Date.parse("#{this} : 00:00"))
  dateArray = date.toArray()
  return "#{dateArray[1]}-#{dateArray[0]}"
  

Date.prototype.toArray= (monthFormat="MMM") ->
  months = ['Enero','Febrero','Marzo','April','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre']
  monthsMMM = ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dec']
  
  month = if monthFormat == "MMM" then monthsMMM[this.getMonth()] else months[this.getMonth()]
  date = this.getDate()
  date = "0" + date if date < 10

  return [date , month , this.getFullYear()]


  

Date.prototype.toSimple = ->
  months = this.getMonth() + 1
  months = "0" + months if months < 10
 
  date = this.getDate()
  date = "0" + date if date < 10
  str = ""
  str += this.getFullYear()
  str += "-"
  str += months
  str += "-"
  str += date
  str

Date.prototype.to_salesforce_date = ->
  months = this.getMonth() + 1
  months = "0" + months if months < 10
 
  date = this.getDate()
  date = "0" + date if date < 10
 
  str = ""
  str += this.getFullYear()
  str += "-"
  str += months
  str += "-"
  str += date
  return str

Date.prototype.to_salesforce = ->
  hours = this.getUTCHours()
  hours = "0" + hours if hours < 10
 
  minutes = this.getUTCMinutes()
  minutes = "0" + minutes if minutes < 10
 
  months = this.getUTCMonth() + 1
  months = "0" + months if months < 10
 
  date = this.getUTCDate()
  date = "0" + date if date < 10
 
  str = ""
  str += this.getUTCFullYear()
  str += "-"
  str += months
  str += "-"
  str += date
  str += "T"
  str += hours
  str += ":"
  str += minutes
  str += ":"
  str += "00Z"
  return str


Date.prototype.getWeek = ->
  onejan = new Date(this.getFullYear(),0,1);
  return Math.ceil((((this - onejan) / 86400000) + onejan.getDay()+1)/7);


Date.prototype.days_from_now = ->
  date =this 
  diff = (((new Date()).getTime() - date.getTime()) / 1000)
  day_diff = Math.floor(diff / 86400)

Date.prototype.weeksFromToday= ->
  date =this 
  diff = (((new Date()).getTime() - date.getTime()) / 1000)
  day_diff = Math.floor(diff / (86400 * 7 ) )


Date.prototype.minutes_from_now = ->
	date =this 
	diff = (((new Date()).getTime() - date.getTime()) / 1000)
#	day_diff = Math.floor(diff / 86400);
	return diff / 60


Date.prototype.to_pretty = ->

	date =this 
	diff = (((new Date()).getTime() - date.getTime()) / 1000)
	day_diff = Math.floor(diff / 86400);

	if(diff > 0)
		if ( isNaN(day_diff) || day_diff < 0 || day_diff > 700 )
		  return "Primera Vez"

		return day_diff == 0 && (
				diff < 60 && "justo ahora" ||
				diff < 3600 && "hace " + Math.floor( diff / 60 ) + " minutos" ||
				diff < 86400 &&  Math.floor( diff / 3600 ) + " horas atras") ||
			  day_diff == 1 && "Ayer" ||
			  day_diff < 15 &&   day_diff + " dias atras" ||
			  day_diff < 31 &&   Math.ceil( day_diff / 7 ) + " semanas atras" ||
			  day_diff < 700 &&  Math.ceil( day_diff / 30 ) + " meses atras"
	else
		diff = Math.abs(diff)
		day_diff = Math.abs(day_diff)

		if ( isNaN(day_diff) || day_diff < 0 || day_diff > 700 )
		  return "Primera Vez"

		return day_diff == 0 && (
			diff < 3600 && Math.floor( diff / 60 ) + " minutos " ||
			diff < 86400 &&  Math.floor( diff / 3600 ) + " horas ") ||
			day_diff == 1 && "Manana" ||
			day_diff < 60 &&   "en " + day_diff + " dias" ||
			day_diff < 100 &&  "en " + Math.ceil( day_diff / 7 ) + " semanas" ||
			day_diff < 700 &&  "en " + Math.ceil( day_diff / 30 ) + " meses";
	

