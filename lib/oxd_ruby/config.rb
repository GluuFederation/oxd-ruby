# This file stores default configuration values for Oxd commands.
# @author Inderpal Singh
# @version 2.4.3

module OxdRuby
	class << self
		attr_accessor :configuration
	end

	def self.configure
		self.configuration ||= Configuration.new
		if block_given?
			yield(configuration)
		end
	end

	class Configuration
		attr_accessor :oxd_id, :oxd_host_ip, :oxd_host_port, :authorization_redirect_uri, :logout_redirect_uri, :post_logout_redirect_uri, :scope, :application_type, :redirect_uris, :response_types, :client_jwks_uri, :client_token_endpoint_auth_method, :client_request_uris, :contacts, :grant_types, :acr_values, :client_logout_uris

		def initialize
			@oxd_id								= ""
			@oxd_host_ip                		= '127.0.0.1'
			@oxd_host_port      				= 8099
			@authorization_redirect_uri 		= ""
			@logout_redirect_uri 				= ""
			@post_logout_redirect_uri			= ""
			@scope					  			= [ "openid", "profile" ]
			@application_type       			= "web"
			@redirect_uris     		  			= [ "" ]
			@response_types     				= ["code"]
			@client_jwks_uri			  		= ""
			@client_token_endpoint_auth_method	= ""
			@client_request_uris				= [ "" ]
			@contacts							= [ "" ]
			@grant_types 						= "authorization_code"
			@acr_values 						= [ "basic", "duo" ]
			@client_logout_uris		  			= [ "" ]
		end
	end
end