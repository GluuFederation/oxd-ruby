# @author Inderpal Singh
# @note supports oxd-version 3.1.1
module Oxd

	require 'json'

	# This class carries out the commands to talk with the oxD server.
	# The oxD request commands are provided as class methods that can be called to send the command 
	# 	to the oxD server via socket and the reponse is returned as a dict by the called method.
	class ClientOxdCommands < OxdConnector	

		# class constructor
		def initialize
			super
		end

		# @return [String] oxd_id of the registered website
		# method to setup the client and generate a Client ID, Client Secret for the site
		# works with oxd-to-https and oxd-server
		def setup_client
			@command = 'setup_client'
			@params = {
				"authorization_redirect_uri" => @configuration.authorization_redirect_uri,
				"op_host" => @configuration.op_host,
				"post_logout_redirect_uri" => @configuration.post_logout_redirect_uri,
				"application_type" => @configuration.application_type,
				"response_types"=> @configuration.response_types,
	            "grant_types" => @configuration.grant_types,
	            "scope" => @configuration.scope,
	            "acr_values" => @configuration.acr_values,
	            "client_jwks_uri" => @configuration.client_jwks_uri,
				"client_name" => @configuration.client_name,
				"client_token_endpoint_auth_method" => @configuration.client_token_endpoint_auth_method,
				"client_request_uris" => @configuration.client_request_uris,
				"client_logout_uris"=> @configuration.client_logout_uris,
				"client_sector_identifier_uri" => @configuration.client_sector_identifier_uri,
				"contacts" => @configuration.contacts,
				"ui_locales" => @configuration.ui_locales,
				"claims_locales" => @configuration.claims_locales,
				"client_id" => @configuration.client_id,
		        "client_secret" => @configuration.client_secret,
		        "oxd_rp_programming_language" => 'ruby',
				"protection_access_token" => @configuration.protection_access_token
			}
			request('setup-client')
	        @configuration.client_id = getResponseData['client_id']
	        @configuration.client_secret = getResponseData['client_secret']
	        @configuration.oxd_id = getResponseData['oxd_id']

		end

		# @return [String] oxd_id of the registered website
		# method to register the website and generate a unique ID for that website
		# works with oxd-to-https and oxd-server
		def register_site	
			if(!@configuration.oxd_id.empty?) # Check if client is already registered
				return @configuration.oxd_id
			else
				@command = 'register_site'
				@params = {
		        	"authorization_redirect_uri" => @configuration.authorization_redirect_uri,
					"op_host" => @configuration.op_host,
		            "post_logout_redirect_uri" => @configuration.post_logout_redirect_uri,
		            "application_type" => @configuration.application_type,		            
		            "response_types"=> @configuration.response_types,
		            "grant_types" => @configuration.grant_types,
		            "scope" => @configuration.scope,
		            "acr_values" => @configuration.acr_values,
		            "client_jwks_uri" => @configuration.client_jwks_uri,
		            "client_token_endpoint_auth_method" => @configuration.client_token_endpoint_auth_method,
		            "client_request_uris" => @configuration.client_request_uris,
		            "client_logout_uris"=> @configuration.client_logout_uris,
		            "contacts" => @configuration.contacts,
		            "client_id" => @configuration.client_id,
		            "client_secret" => @configuration.client_secret,
					"client_name" => @configuration.client_name,
					"client_sector_identifier_uri" => @configuration.client_sector_identifier_uri,
					"ui_locales" => @configuration.ui_locales,
					"claims_locales" => @configuration.claims_locales,
					"protection_access_token" => @configuration.protection_access_token
		        }
		        request('register-site')
		        logger(:log_msg => "OXD ID FROM setup_client : "+getResponseData['oxd_id'])
		        @configuration.oxd_id = getResponseData['oxd_id']
		    end	        
		end

		# @return [STRING] access_token
		# method to generate the protection access token
		# obtained access token is passed as protection_access_token to all further calls to oxd-https-extension
		def get_client_token
			@command = 'get_client_token'
			@params = {
	        	"oxd_id" => @configuration.oxd_id,
				"authorization_redirect_uri" => @configuration.authorization_redirect_uri,
				"op_host" => @configuration.op_host,
				"post_logout_redirect_uri" => @configuration.post_logout_redirect_uri,
				"application_type" => @configuration.application_type,		            
				"response_types"=> @configuration.response_types,
				"grant_types" => @configuration.grant_types,
				"scope" => @configuration.scope,
				"acr_values" => @configuration.acr_values,
				"client_name" => @configuration.client_name,
				"client_jwks_uri" => @configuration.client_jwks_uri,
				"client_token_endpoint_auth_method" => @configuration.client_token_endpoint_auth_method,
				"client_request_uris" => @configuration.client_request_uris,
				"client_sector_identifier_uri" => @configuration.client_sector_identifier_uri,
				"contacts" => @configuration.contacts,
				"ui_locales" => @configuration.ui_locales,
				"claims_locales" => @configuration.claims_locales,
				"client_id" => @configuration.client_id,
				"client_secret" => @configuration.client_secret,
				"client_frontchannel_logout_uris"=> @configuration.client_logout_uris,
				"oxd_rp_programming_language" => 'ruby'
	        }
	        request('get-client-token')
	        @configuration.protection_access_token = getResponseData['access_token']
		end

		# @param scope [Array] OPTIONAL, scopes required, takes the scopes registered with register_site by defualt
		# @param acr_values [Array] OPTIONAL, list of acr values in the order of priority
		# @param custom_params [Hash] OPTIONAL, custom parameters		
		# @return [String] authorization_url
		# method to get authorization url that the user must be redirected to for authorization and authentication
		# works with oxd-to-https and oxd-server
		def get_authorization_url(scope = [], acr_values = [], custom_params = {})
			logger(:log_msg => "@configuration object params #{@configuration.inspect}", :error => "")
			
			@command = 'get_authorization_url'			
			@params = {
	            "oxd_id" => @configuration.oxd_id,
	            "prompt" => @configuration.prompt,
	            "scope" => (scope.blank?)? @configuration.scope : scope,	            
	            "acr_values" => (acr_values.blank?)? @configuration.acr_values : acr_values,
	            "custom_parameters" => custom_params,
				"protection_access_token" => @configuration.protection_access_token
        	}
        	logger(:log_msg => "get_authorization_url params #{@params.inspect}", :error => "")
		    request('get-authorization-url')
		    getResponseData['authorization_url']
		end

		# @param code [String] code obtained from the authorization url callback
		# @param state [String] state obtained from the authorization url callback
		# @return [Hash] {:access_token, :id_token}
		# method to retrieve access token. It is called after the user authorizes by visiting the authorization url.
		# works with oxd-to-https and oxd-server
		def get_tokens_by_code( code, state )
            if (code.empty?)
            	logger(:log_msg => "Empty/Wrong value in place of code.")
        	end
			@command = 'get_tokens_by_code'
			@params = {
	            "oxd_id" => @configuration.oxd_id,
	            "code" => code,
	            "state" => state,
	            "protection_access_token" => @configuration.protection_access_token
        	}        	
			request('get-tokens-by-code')
			@configuration.id_token = getResponseData['id_token']
			@configuration.refresh_token = getResponseData['refresh_token']
			getResponseData['access_token']
		end

		# @param scope [Array] OPTIONAL, scopes required, takes the scopes registered with register_site by defualt
		# @return [String] access_token
		# method to retrieve access token. It is called after getting the refresh_token by using the code and state.
		# works with oxd-to-https and oxd-server		
		def get_access_token_by_refresh_token(scope = nil)
			@command = 'get_access_token_by_refresh_token'
			@params = {
	            "oxd_id" => @configuration.oxd_id,
	            "refresh_token" => @configuration.refresh_token,
	            "scope" => (scope.blank?)? @configuration.scope : scope,
	            "protection_access_token" => @configuration.protection_access_token
        	}        	
			request('get-access-token-by-refresh-token')
			getResponseData['access_token']
		end

		# @param access_token [String] access token recieved from the get_tokens_by_code command
		# @return [String] user data claims that are returned by the OP
		# get the information about the user using the access token obtained from the OP
		# works with oxd-to-https and oxd-server
		def get_user_info(access_token)
			if access_token.empty?
	            logger(:log_msg => "Empty access code sent for get_user_info", :error => "Empty access code")
	        end
			@command = 'get_user_info'
	    	@params = {
	            "oxd_id" => @configuration.oxd_id,
	            "access_token" => access_token,
	            "protection_access_token" => @configuration.protection_access_token
        	}
        	request('get-user-info')
			getResponseData['claims']
		end
	
		# @param state [String] OPTIONAL, website state obtained from the authorization url callback
		# @param session_state [String] OPTIONAL, session state obtained from the authorization url callback
		# @return [String] uri
		# method to retrieve logout url from OP. User must be redirected to this url to perform logout
		# works with oxd-to-https and oxd-server
		def get_logout_uri( state = nil, session_state = nil)
			@command = 'get_logout_uri'
			@params = {
	            "oxd_id" => @configuration.oxd_id,
	            "id_token_hint" => @configuration.id_token,
	            "post_logout_redirect_uri" => @configuration.post_logout_redirect_uri, 
	            "state" => state,
	            "session_state" => session_state,
	            "protection_access_token" => @configuration.protection_access_token
        	}
        	request('get-logout-uri')
        	getResponseData['uri']
		end

		# @return [Boolean] status - if site registration was updated successfully or not
		# method to update the website's information with OpenID Provider. 
		# 	This should be called after changing the values in the oxd_config file.
		# works with oxd-to-https and oxd-server
		def update_site_registration
	    	@command = 'update_site_registration'
        	@params = {
	        	"oxd_id" => @configuration.oxd_id,
				"authorization_redirect_uri" => @configuration.authorization_redirect_uri,
				"post_logout_redirect_uri" => @configuration.post_logout_redirect_uri,
				"client_logout_uris"=> @configuration.client_logout_uris,
				"response_types"=> @configuration.response_types,
				"grant_types" => ["authorization_code","client_credentials","uma_ticket"],
				"scope" => @configuration.scope,
				"acr_values" => @configuration.acr_values,
				"client_name" => @configuration.client_name,
				"client_secret_expires_at" => 3080736637943,
				"client_jwks_uri" => @configuration.client_jwks_uri,
				"client_token_endpoint_auth_method" => @configuration.client_token_endpoint_auth_method,
				"client_request_uris" => @configuration.client_request_uris,
				"client_sector_identifier_uri" => @configuration.client_sector_identifier_uri,
				"contacts" => @configuration.contacts,
				"ui_locales" => @configuration.ui_locales,
				"claims_locales" => @configuration.claims_locales,
				"protection_access_token" => @configuration.protection_access_token
	        }
	        request('update-site')
	        if @response_object['status'] == "ok"
	        	@configuration.oxd_id = getResponseData['oxd_id']
	            return true
	        else
	            return false
	        end
		end

		# @return Oxd Configuraton object
		def oxdConfig
			return @configuration
		end
	end
end
