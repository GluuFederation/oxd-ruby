# @author Inderpal Singh
# @note supports oxd-version 3.1.2
module Oxd

	require 'json'

	# This class carries out the commands to talk with the oxd server.
	# The oxd request commands are provided as class methods that can be called to send the command 
	# 	to the oxd server via socket and the reponse is returned as a dict by the called method.
	class ClientOxdCommands < OxdConnector	

		# class constructor
		def initialize
			super
		end

		# @return [String] oxd_id of the registered website
		# method to setup the client and generate a Client ID, Client Secret for the site		
		def setup_client
			@command = 'setup_client'
			@params = client_params.merge(register_params)
			request('setup-client')
	        @configuration.client_id = getResponseData['client_id']
	        @configuration.client_secret = getResponseData['client_secret']
	        @configuration.oxd_id = getResponseData['oxd_id']
		end

		# @return [String] oxd_id of the registered website
		# method to register the website and generate a unique ID for that website		
		def register_site	
			# Check if client is already registered
			# @return registered oxd_id
			if(!@configuration.oxd_id.empty?)
				return @configuration.oxd_id
			else
				@command = 'register_site'
				@params = client_params.merge(register_params)
				@params = @params.merge({"protection_access_token" => @configuration.protection_access_token})
		        request('register-site')
		        logger("oxd Id from register_site : "+getResponseData['oxd_id'])
		        @configuration.oxd_id = getResponseData['oxd_id']
		    end	        
		end

		# @param op_discovery_path [STRING] OPTIONAL, op discovery path provided by OP
		# @return [STRING] access_token
		# method to generate the protection access token
		# obtained access token is passed as protection_access_token to all further calls to oxd-https-extension
		def get_client_token(op_discovery_path = nil)
			@command = 'get_client_token'
			@params = {
				"op_host" => @configuration.op_host,
				"scope" => @configuration.scope,
				"client_id" => @configuration.client_id,
				"client_secret" => @configuration.client_secret,
				"op_discovery_path" => (op_discovery_path.blank?)? @configuration.op_discovery_path : op_discovery_path,
	        }
	        request('get-client-token')
	        @configuration.protection_access_token = getResponseData['access_token']
		end

		# @return [OBJECT] @response_data
		# method to gain information about an access token
		def introspect_access_token
			@command = 'introspect_access_token'
			@params = {
				"oxd_id" => @configuration.oxd_id,
				"access_token" => @configuration.protection_access_token
	        }
	        request('introspect-access-token')
	        getResponseData
		end

		# @param scope [Array] OPTIONAL, scopes required, takes the scopes registered with register_site by defualt
		# @param acr_values [Array] OPTIONAL, list of acr values in the order of priority
		# @param custom_params [Hash] OPTIONAL, custom parameters		
		# @return [String] authorization_url
		# method to get authorization url that the user must be redirected to for authorization and authentication		
		def get_authorization_url(scope: [], acr_values: [], custom_params: {})
			logger("@configuration object params #{@configuration.inspect}")
			
			@command = 'get_authorization_url'			
			@params = {
	            "oxd_id" => @configuration.oxd_id,
	            "prompt" => @configuration.prompt,
	            "scope" => (scope.blank?)? @configuration.scope : scope,	            
	            "acr_values" => (acr_values.blank?)? @configuration.acr_values : acr_values,
	            "custom_parameters" => custom_params,
				"protection_access_token" => @configuration.protection_access_token
        	}
        	logger("get_authorization_url params #{@params.inspect}")
		    request('get-authorization-url')
		    getResponseData['authorization_url']
		end

		# @param code [String] code obtained from the authorization url callback
		# @param state [String] state obtained from the authorization url callback
		# @return [String] access_token
		# method to retrieve access token. It is called after the user authorizes by visiting the authorization url.		
		def get_tokens_by_code( code, state )
            if (code.empty?)
            	trigger_error("Empty/Wrong value in place of code.")
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
		def get_user_info(access_token)
			if access_token.empty?
	            trigger_error("Empty access code sent for get_user_info")
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
		def update_site
	    	@command = 'update_site'
        	@params = client_params.merge(
        		{
		        	"oxd_id" => @configuration.oxd_id,
					"client_secret_expires_at" => 3080736637943,
					"protection_access_token" => @configuration.protection_access_token
				}
        	)				
	        request('update-site')
	        if @response_object['status'] == "ok"
	        	@configuration.oxd_id = getResponseData['oxd_id']
	            return true
	        else
	            return false
	        end
		end

		# @return [String] oxd_id - if site data was cleaned successfully
		# method to clean up the website's information from OpenID Provider. 		
		def remove_site
	    	@command = 'remove_site'
        	@params = {
	        	"oxd_id" => @configuration.oxd_id,
	        	"protection_access_token" => @configuration.protection_access_token
	        }
	        request('remove-site')
	        if @response_object['status'] == "ok"
	        	@configuration.oxd_id = getResponseData['oxd_id']	            
	        end
		end

		# @return [HASH] client_params
		# common params to use with client setup commands
		# ie. setup_client, register_site and update_site
		def client_params
			client_params = {
				"authorization_redirect_uri" => @configuration.authorization_redirect_uri,
				"post_logout_redirect_uri" => @configuration.post_logout_redirect_uri,
				"response_types"=> @configuration.response_types,
				"grant_types" => @configuration.grant_types,
				"scope" => @configuration.scope,
				"acr_values" => @configuration.acr_values,
				"client_jwks_uri" => @configuration.client_jwks_uri,
				"client_name" => @configuration.client_name,
				"client_token_endpoint_auth_method" => @configuration.client_token_endpoint_auth_method,
				"client_request_uris" => @configuration.client_request_uris,
				"client_frontchannel_logout_uris" => @configuration.client_frontchannel_logout_uris,
				"client_sector_identifier_uri" => @configuration.client_sector_identifier_uri,
				"contacts" => @configuration.contacts,
				"ui_locales" => @configuration.ui_locales,
				"claims_locales" => @configuration.claims_locales
			}
		end

		# @return [HASH] register_params
		# common params to use with register_site and setup_client commands		
		def register_params
			register_params = {
				"op_host" => @configuration.op_host,
				"application_type" => @configuration.application_type,
				"claims_redirect_uri" => @configuration.claims_redirect_uri,
				"client_id" => @configuration.client_id,
		        "client_secret" => @configuration.client_secret
			}
		end

		# @return oxd Configuraton object
		def oxdConfig
			return @configuration
		end
	end
end