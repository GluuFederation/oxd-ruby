# This class carries out the commands to talk with the oxD server. The oxD request commands are provided as class methods that can be called to send the command to the oxD server via socket and the reponse is returned as a dict by the called method.
# @author Inderpal Singh
# @oxd-version 2.4.3

module Oxd
	class ClientOxdCommands < ClientOxdRp

		# ClientOxdRp initialization
		def initialize
			@configuration = Oxd.config
			super
		end
		
	    # Returns:
        # => The oxd_id (mixed) of the registration of website
	    def getOxdId
        	return @configuration.oxd_id
	    end

		# Function to register the website and generate a unique ID for that website
		# Returns:
        # => The oxd_id (mixed) of the registration of website
		def register_site			
			if(@configuration.oxd_id.present?) # Check if client is already registered
				return @configuration.oxd_id
			else
				@command = 'register_site'
				@configuration.scope = [ "openid", "profile","email"]
				@params = {
		        	"authorization_redirect_uri" => @configuration.authorization_redirect_uri,
		            "post_logout_redirect_uri" => @configuration.post_logout_redirect_uri,
		            "application_type" => @configuration.application_type,
		            "redirect_uris" => @configuration.redirect_uris,
		            "acr_values" => @configuration.acr_values,
		            "scope" => @configuration.scope,
		            "client_jwks_uri" => @configuration.client_jwks_uri,
		            "client_token_endpoint_auth_method" => @configuration.client_token_endpoint_auth_method,
		            "client_request_uris" => @configuration.client_request_uris,
		            "contacts" => @configuration.contacts,
		            "grant_types" => @configuration.grant_types,
		            "response_types"=> @configuration.response_types,
		            "client_logout_uris"=> @configuration.client_logout_uris
		        }
		        request
		        @configuration.oxd_id = getResponseData['oxd_id']
		    end	        
		end

		# Function to get the authorization url that can be opened in the browser for the user to provide authorization and authentication
        # Args:
        # => acr_values (list): OPTIONAL list of acr values in the order of priority
        # Returns:
        # => The authorization url (string) that the user must access for authentication and authorization
		def get_authorization_url
			@command = 'get_authorization_url'
			@params = {
	            "oxd_id" => @configuration.oxd_id,
	            "acr_values" => @configuration.acr_values
        	}
		    request
		    getResponseData['authorization_url']
		end

		# Function to get access code for getting the user details from the OP. It is called after the user authorizes by visiting the auth URL.
        # Args:
        # => code (string): code obtained from the auth url callback
        # => scopes (list): scopes authorized by the OP, from the url callback
        # => state (string): state key obtained from the auth url callback
        # Returns:
        # => The access token (string) which should be passed to get the user information from the OP
		def get_tokens_by_code( code, scopes, state = nil)
			@command = 'get_tokens_by_code'
			@params = {
	            "oxd_id" => @configuration.oxd_id,
	            "code" => code,
	            "scopes" => scopes,
	            "state" => state
        	}
			request
			getResponseData['access_token']
		end

		# Function to get access code for getting the user details from the OP. It is called after the user authorizies by visiting the auth URL.
		# Args:
        # => url (string): the callback url which was called by the OP after user authorization which has the states, code and scopes as query parameters
		# Returns:
        # => The access token (string) which should be passed to get the user information from the OP
		def get_tokens_by_code_by_url(url)
			@command = 'get_tokens_by_code'
			@params = {
	            "oxd_id" => @configuration.oxd_id,
	            "url"	 => url
        	}
			request
			getResponseData['access_token']
		end

		# Function to get the information about the user using the access token obtained from the OP
		# Args:
        # => access_token (string): access token from the get_tokens_by_code function
		# Returns:
        # => The user data claims (named tuple) that are returned by the OP
		def get_user_info(access_token)
			@command = 'get_user_info'
	    	@params = {
	            "oxd_id" => @configuration.oxd_id,
	            "access_token" => access_token
        	}
        	request
			getResponseData['claims']
		end

		# Function to logout the user.
		# Args:
        # => id_token_hint (string): OPTIONAL (oxd server will use last used access token)
        # => post_logout_redirect_uri (string): OPTIONAL URI for redirection, this uri would override the value given in the website-config
        # => state (string): OPTIONAL website state
        # => session_state (string): OPTIONAL session state
        # Returns:
        # => The URI (string) to which the user must be directed in order to perform the logout
		def get_logout_uri(access_token, state, session_state)
			@command = 'get_logout_uri'
			@params = {
	            "oxd_id" => @configuration.oxd_id,
	            "id_token_hint" => access_token,
	            "post_logout_redirect_uri" => @configuration.post_logout_redirect_uri,
	            "state" => state,
	            "session_state" => session_state
        	}
        	request
        	getResponseData['uri']
		end

		# Fucntion to update the website's information with OpenID Provider.
        # This should be called after changing the values in the config file.
        # Returns:
        # => The status (boolean) for update of information was sucessful or not
		def update_site_registration
	    	@command = 'update_site_registration'
        	@params = {
	        	"authorization_redirect_uri" => @configuration.authorization_redirect_uri,
	        	"oxd_id" => @configuration.oxd_id,
	            "post_logout_redirect_uri" => @configuration.post_logout_redirect_uri,
	            "application_type" => @configuration.application_type,
	            "redirect_uris" => @configuration.redirect_uris,
	            "acr_values" => @configuration.acr_values,
	            "scope" => @configuration.scope,
	            "client_jwks_uri" => @configuration.client_jwks_uri,
	            "client_token_endpoint_auth_method" => @configuration.client_token_endpoint_auth_method,
	            "client_request_uris" => @configuration.client_request_uris,
	            "contacts" => @configuration.contacts,
	            "grant_types" => @configuration.grant_types,
	            "response_types"=> @configuration.response_types,
	            "client_secret_expires_at" => 1916258400,
	            "client_logout_uris"=> @configuration.client_logout_uris
	        }
	        request
	        getResponseObject['status']
		end

	end
end
