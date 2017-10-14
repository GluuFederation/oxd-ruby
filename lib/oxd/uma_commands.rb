# @author Inderpal Singh
# @note supports oxd-version 3.1.1
module Oxd

	require 'json'

	# This class carries out the commands for UMA Resource Server and UMA Requesting Party
	class UMACommands < OxdConnector

		# class constructor
		def initialize
			@resources = Array.new
			super
		end	

		# @param path [STRING] REQUIRED
		# @param conditions [HASH] REQUIRED (variable number of conditions can be passed)
		# @return [ARRAY] resources
		# @example
		#   condition1 = {:httpMethods => ["GET"], :scopes => ["http://photoz.example.com/dev/actions/view"]}
		#   condition2 = {:httpMethods => ["PUT", "POST"], :scopes => ["http://photoz.example.com/dev/actions/all","http://photoz.example.com/dev/actions/add"],:ticketScopes => ["http://photoz.example.com/dev/actions/add"]}
		#   uma_add_resource("/photo", condition1, condition2)
		# combines multiple resources into @resources array to pass to uma_rs_protect method
		def uma_add_resource(path, *conditions)			
		    @resources.push({:path => path, :conditions => conditions})			
		end

		# @return [STRING] oxd_id
		# @raise RuntimeError if @resources is nil
		# method to protect resources with UMA resource server
		def uma_rs_protect
			logger(:log_msg => "Please set resources with uma_add_resource(path, *conditions) method first.") if(@resources.nil?)
			logger(:log_msg => "UMA configuration #{@configuration}", :error => '')
			@command = 'uma_rs_protect'
			@params = {
				"oxd_id" => @configuration.oxd_id,
				"resources" => @resources,
				"protection_access_token" => @configuration.protection_access_token
			}
	        request('uma-rs-protect')
	        getResponseData['oxd_id']
		end

		# @param claim_token [STRING] OPTIONAL
		# @param claim_token_format [STRING] OPTIONAL
		# @param pct [STRING] OPTIONAL
		# @param rpt [STRING] OPTIONAL
		# @param scope [STRING] OPTIONAL
		# @param state [STRING] OPTIONAL, state that is returned from uma_rp_get_claims_gathering_url command
		# @return [Hash] response data (access_token, token_type, pct, upgraded)
		# method for obtaining RPT to gain access to protected resources at the UMA resource server
		def uma_rp_get_rpt( claim_token = nil, claim_token_format = nil, pct = nil, rpt = nil, scope = nil, state = nil )
			@command = 'uma_rp_get_rpt'
			@params = {
				"oxd_id" => @configuration.oxd_id,
				"ticket" => @configuration.ticket,
				"claim_token" => claim_token,
				"claim_token_format" => claim_token_format,
				"pct" => pct,
				"rpt" => (!rpt.nil?)? rpt : @configuration.rpt,
				"scope" => scope,
				"state" => state,
				"protection_access_token" => @configuration.protection_access_token
	        }
	        request('uma-rp-get-rpt')
	        
	        if getResponseData['error'] == 'need_info' && !getResponseData['details']['ticket'].empty?
	        	@configuration.ticket = getResponseData['details']['ticket']	        
	        end

	        getResponseData
		end

		# @param path [STRING] REQUIRED
		# @param http_method [Array] REQUIRED, must be one from 'GET', 'POST', 'PUT', 'DELETE'
		# @return [Hash] response data (access, ticket)
		# method to check if we have permission to access particular resource or not
		def uma_rs_check_access(path, http_method)
			if (path.empty? || http_method.empty? || (!['GET', 'POST', 'PUT', 'DELETE'].include? http_method))
            	logger(:log_msg => "Empty/Wrong value in place of path or http_method.")
        	end
			@command = 'uma_rs_check_access'
			@params = {
				"oxd_id" => @configuration.oxd_id,
				"rpt" => @configuration.rpt,
				"path" => path,
				"http_method" => http_method,
				"protection_access_token" => @configuration.protection_access_token
	        }
	        request('uma-rs-check-access')
	        if getResponseData['access'] == 'denied' && !getResponseData['ticket'].empty?
	        	@configuration.ticket = getResponseData['ticket']
	        elsif getResponseData['access'] == 'granted' 
	        	@configuration.ticket = ""
	        end
	        getResponseData
		end

		# @param claims_redirect_uri [STRING] REQUIRED
		# @return [Hash] response data (url, state)
		# method to check if we have permission to access particular resource or not
		def uma_rp_get_claims_gathering_url( claims_redirect_uri )
			if (claims_redirect_uri.empty?)
            	logger(:log_msg => "Empty/Wrong value in place of claims_redirect_uri.")
        	end
			@command = 'uma_rp_get_claims_gathering_url'
			@params = {
				"oxd_id" => @configuration.oxd_id,
				"ticket" => @configuration.ticket,
				"claims_redirect_uri" => claims_redirect_uri,
				"protection_access_token" => @configuration.protection_access_token
	        }
	        request('uma-rp-get-claims-gathering-url')	        
	        getResponseData
		end			
	end
end