# Sample config file
Oxd.configure do |config|
  	config.oxd_host_ip                			= '127.0.0.1'
	config.oxd_host_port      		  			= 8099
	config.authorization_redirect_uri 			= "https://oxd-ruby.com/login"
	config.logout_redirect_uri 		  			= "https://oxd-ruby.com/logout"
	config.post_logout_redirect_uri	  			= "https://oxd-ruby.com"
	config.scope					  			= [ "openid", "profile" ]
	config.application_type       	  			= "web"
	config.redirect_uris     		  			= ["https://oxd-ruby.com/login" ]
	config.client_jwks_uri			  			= ""
	config.client_token_endpoint_auth_method	= ""
	config.client_request_uris					= []
	config.contacts								= ["example-email@gmail.com"]
	config.grant_types							= []
	config.response_types     		  			= ["code"]
	config.acr_values 				  			= ["basic"]
	config.client_logout_uris		  			= ['https://oxd-ruby.com/logout']
end