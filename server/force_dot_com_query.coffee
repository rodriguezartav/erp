
queryDoc: (forceOAuth,query) =>
  
  options = 
  	host: forceOAuth.getOAuthResponse().instance_url,
  	path: '/services/data/v20.0/query/?q=' + query,
  	method: 'GET',
  	headers:
  		'host': hostname,
  		'Authorization': "OAuth #{forceOAuth.getOAuthResponse().access_token}"
  	

  req = http.request(options, res) =>
    console.log("statusCode: ", res.statusCode);
    console.log("headers: ", res.headers);
    console.log("bidy: ", res.body);