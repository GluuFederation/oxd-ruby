# Sample config file
Oxd.configure do |config|
  	config.oxd_host_ip                			= '127.0.0.1'
	config.oxd_host_port      		  			= 8099
	config.op_host					 			= "https://your.openid.provider.com"
	config.client_id 							= ""
	config.client_secret 						= ""
	config.client_name 							= "Gluu Oxd Sample Client"
	config.authorization_redirect_uri 			= "https://domain.example.com/callback"
	config.logout_redirect_uri 		  			= "https://domain.example.com/callback2"
	config.post_logout_redirect_uri	  			= "https://domain.example.com/logout"
	config.scope					  			= ["openid","profile", "email", "uma_protection","uma_authorization"]
	config.grant_types							= []
	config.application_type       	  			= "web"
	config.response_types     		  			= ["code"]
	config.acr_values 				  			= ["basic"]
	config.client_jwks_uri			  			= ""
	config.client_token_endpoint_auth_method	= ""
	config.client_request_uris					= []
	config.contacts								= ["example-email@gmail.com"]
	config.client_logout_uris		  			= ['https://domain.example.com/logout']
	config.oxd_host 							= ""
	config.connection_type 						= "local"
	config.dynamic_registration					= true
end