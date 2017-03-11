# @author Inderpal Singh
# @note supports oxd-version 2.4.4
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
		# method to register the website and generate a unique ID for that website
		def register_site			
			if(!@configuration.oxd_id.empty?) # Check if client is already registered
				return @configuration.oxd_id
			else
				@command = 'register_site'
				@params = {
					"op_host" => @configuration.op_host,
		        	"authorization_redirect_uri" => @configuration.authorization_redirect_uri,
		            "post_logout_redirect_uri" => @configuration.post_logout_redirect_uri,
		            "application_type" => @configuration.application_type,		            
		            "acr_values" => @configuration.acr_values,
		            "scope" => @configuration.scope,
		            "client_jwks_uri" => @configuration.client_jwks_uri,
		            "client_token_endpoint_auth_method" => @configuration.client_token_endpoint_auth_method,
		            "client_request_uris" => @configuration.client_request_uris,
		            "contacts" => @configuration.contacts,
		            "grant_types" => @configuration.grant_types,
		            "response_types"=> @configuration.response_types,
		            "client_logout_uris"=> @configuration.client_logout_uris,
		            "client_secret"=> @configuration.client_secret,
		            "client_id"=> @configuration.client_id
		        }
		        request
		        @configuration.oxd_id = getResponseData['oxd_id']
		    end	        
		end

		# @return [String] stored(in oxd_config) oxd_id of the registered website
	    def getOxdId
        	return @configuration.oxd_id
	    end
		
		# @param acr_values [Array] OPTIONAL, list of acr values in the order of priority
		# @return [String] authorization_url
		# method to get authorization url that the user must be redirected to for authorization and authentication
		def get_authorization_url(acr_values = [""])
			@command = 'get_authorization_url'
			@params = {
	            "oxd_id" => @configuration.oxd_id,
	            "prompt" => @configuration.prompt,
	            "acr_values" => acr_values || @configuration.acr_values
        	}
		    request
		    getResponseData['authorization_url']
		end

		# @param code [String] code obtained from the authorization url callback
		# @param state [String] state obtained from the authorization url callback
		# @return [Hash] {:access_token, :id_token}
		# method to retrieve access token. It is called after the user authorizes by visiting the authorization url.
		def get_tokens_by_code( code,state )
            if (code.empty?)
            	logger(:log_msg => "Empty/Wrong value in place of code.")
        	end
			@command = 'get_tokens_by_code'
			@params = {
	            "oxd_id" => @configuration.oxd_id,
	            "code" => code,
	            "state" => state
        	}        	
			request
			@configuration.id_token = getResponseData['id_token']
			getResponseData['access_token']
		end

		# @param access_token [String] access token recieved from the get_tokens_by_code command
		# @return [String] user data claims that are returned by the OP
		# get the information about the user using the access token obtained from the OP
		def get_user_info(access_token)
			if access_token.empty?
	            logger(:log_msg => "Empty access code sent for get_user_info", :error => "Empty access code")
	        end
			@command = 'get_user_info'
	    	@params = {
	            "oxd_id" => @configuration.oxd_id,
	            "access_token" => access_token
        	}
        	request
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
	            "session_state" => session_state
        	}
        	request
        	getResponseData['uri']
        	#@configuration.oxd_id = "" #unset oxd_id after logout
		end

		# @return [Boolean] status - if site registration was updated successfully or not
		# method to update the website's information with OpenID Provider. 
		# 	This should be called after changing the values in the oxd_config file.
		def update_site_registration
	    	@command = 'update_site_registration'
        	@params = {
	        	"authorization_redirect_uri" => @configuration.authorization_redirect_uri,
	        	"oxd_id" => @configuration.oxd_id,
	            "post_logout_redirect_uri" => @configuration.post_logout_redirect_uri,
	            "application_type" => @configuration.application_type,
	            "acr_values" => @configuration.acr_values,
	            "scope" => @configuration.scope,
	            "client_jwks_uri" => @configuration.client_jwks_uri,
	            "client_token_endpoint_auth_method" => @configuration.client_token_endpoint_auth_method,
	            "client_request_uris" => @configuration.client_request_uris,
	            "contacts" => @configuration.contacts,
	            "grant_types" => @configuration.grant_types,
	            "response_types"=> @configuration.response_types,
	            "client_secret_expires_at" => 3080736637943,
	            "client_logout_uris"=> @configuration.client_logout_uris
	        }
	        request
	        if @response_object['status'] == "ok"
	        	@configuration.oxd_id = getResponseData['oxd_id']
	            return true
	        else
	            return false
	        end
		end
	end
end