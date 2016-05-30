module OxdRuby
	def self.configure(&block)
		if block_given?
			yield @config ||= OxdRuby::Configuration.new
		end
	end

	def self.config
		@config
	end

	# Configuration class
	class Configuration
		include ActiveSupport::Configurable
		
		# Set default Configuration variables
		config_accessor(:oxd_host_ip) {'127.0.0.1'}
		config_accessor(:oxd_host_port) {8099}
		config_accessor(:authorization_redirect_uri) {''}
		config_accessor(:logout_redirect_uri) {''}
		config_accessor(:scope) {[ "openid", "profile" ]}
		config_accessor(:application_type) {"web"}
		config_accessor(:redirect_uris) {''}
		config_accessor(:response_types) {["code"]}
		config_accessor(:grant_types) {"authorization_code"}
		config_accessor(:acr_values) {[ "basic", "duo" ]}	                
	end

	# Set default Configuration variables
=begin
	configure do |config|
		config.oxd_host_ip                = '127.0.0.1'
		config.oxd_host_port      		  = 8099
		config.authorization_redirect_uri = ""
		config.logout_redirect_uri 		  = ""
		config.scope					  = [ "openid", "profile" ]
		config.application_type       	  = "web"
		config.redirect_uris     		  = [ "" ]
		config.response_types     		  = ["code"]
		config.grant_types 				  = "authorization_code"
		config.acr_values 				  = [ "basic", "duo" ]
	end
=end

end