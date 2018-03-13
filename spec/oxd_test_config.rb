# Sample config file
Oxd.configure do |config|
  	config.oxd_host_ip                			= '127.0.0.1'
	config.oxd_host_port      		  			= 8099
	config.op_host					 			= "https://newgluuserver.com"
	config.client_id 							= ""
	config.client_secret 						= ""
	config.client_name 							= "Gluu Oxd Sample Client"
	config.authorization_redirect_uri 			= "https://oxd-rails-app-312.com/login"
	config.client_frontchannel_logout_uris		= "https://oxd-rails-app-312.com/logout"
	config.post_logout_redirect_uri	  			= "https://oxd-rails-app-312.com/"
	config.claims_redirect_uri	  				= ["https://oxd-rails-app-312.com/uma/claims"]
	config.scope					  			= ["openid","profile", "email", "uma_protection","uma_authorization"]
	config.grant_types							= ["authorization_code","client_credentials"]
	config.application_type       	  			= "web"
	config.response_types     		  			= ["code"]
	config.acr_values 				  			= ["basic", "duo"]
	config.client_jwks_uri			  			= ""
	config.client_token_endpoint_auth_method	= ""
	config.client_request_uris					= []
	config.contacts								= ["example-email@gmail.com"]
	config.client_frontchannel_logout_uris		= ['https://oxd-rails-app-312.com/logout']
	config.connection_type 						= "local"
	config.dynamic_registration					= true
end