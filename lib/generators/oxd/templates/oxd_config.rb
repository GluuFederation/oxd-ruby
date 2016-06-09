Oxd.configure do |config|
  	config.oxd_host_ip                			= '127.0.0.1'
	config.oxd_host_port      		  			= 8099
	config.authorization_redirect_uri 			= "https://gluu.example.com/callback"
	config.logout_redirect_uri 		  			= "https://gluu.example.com/callback2"
	config.post_logout_redirect_uri	  			= "https://gluu.example.com/logout"
	config.scope					  			= [ "openid", "profile" ]
	config.application_type       	  			= "web"
	config.redirect_uris     		  			= ["https://gluu.example.com/callback" ]
	config.client_jwks_uri			  			= ""
	config.client_token_endpoint_auth_method	= ""
	config.client_request_uris					= []
	config.contacts								= ["inderpal6785@gmail.com"]
	config.grant_types							= []
	config.response_types     		  			= ["code"]
	config.acr_values 				  			= ["basic"]
	config.client_logout_uris		  			= ['https://gluu.example.com/logout']
end
