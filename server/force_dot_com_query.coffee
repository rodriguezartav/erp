queryDoc: =>

  options = 
  	host: hostname,
  	path: '/services/oauth2/token',
  	method: 'POST',
  	headers:
  		'host': hostname,
  		'Content-Length': post_data.length,
  		'Content-Type': 'application/x-www-form-urlencoded',
  		'Accept':'application/jsonrequest',
  		'Cache-Control':'no-cache,no-store,must-revalidate'
  	

  req = http.request(options, res) =>
  	  console.log("statusCode: ", res.statusCode);
  	  console.log("headers: ", res.headers);