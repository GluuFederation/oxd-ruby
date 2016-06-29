# @author Inderpal Singh
# @note supports oxd-version 2.4.4
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
			@command = 'uma_rs_protect'
			@params = {
				"oxd_id" => @configuration.oxd_id,
				"resources" => @resources
			}
	        request
	        getResponseData['oxd_id']
		end

		# @param force_new [BOOLEAN] REQUIRED
		# @return [STRING] RPT
		# @raise RuntimeError if force_new param is not boolean
		# method for obtaining RPT to gain access to protected resources at the UMA resource server
		def uma_rp_get_rpt(force_new) 
			logger(:log_msg => "Wrong value for force_new param. #{force_new.kind_of?(TrueClass)}") if(force_new.kind_of?(TrueClass) || force_new.kind_of?(FalseClass))
			@command = 'uma_rp_get_rpt'
			@params = {
				"oxd_id" => @configuration.oxd_id,
				"force_new" => force_new
	        }
	        request
	        @configuration.rpt = getResponseData['rpt']
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
				"http_method" => http_method
	        }
	        request
	        if getResponseData['access'] == 'denied' && !getResponseData['ticket'].empty?
	        	@configuration.ticket = getResponseData['ticket']
	        elsif getResponseData['access'] == 'granted' 
	        	@configuration.ticket = ""
	        end
	        getResponseData
		end	

		# @return [String] oxd_id 
		# @note This method should always be called after uma_rp_get_rpt and uma_rs_check_access methods
		# Method to authorize generated RPT using oxd_id and ticket.
		def uma_rp_authorize_rpt
			@command = 'uma_rp_authorize_rpt'
			@params = {
				"oxd_id" => @configuration.oxd_id,
				"rpt" => @configuration.rpt,
				"ticket" => @configuration.ticket
	        }
	        request
	        getResponseData['oxd_id']
		end

		# @param scopes [Array] REQUIRED
		# @return [String] rpt 
		# @example
		# 	scopes = ["http://photoz.example.com/dev/actions/add","http://photoz.example.com/dev/actions/view"]
		# 	uma_rp_get_gat(scopes)
		# method to obtain GAT (Gluu Access Token)
		def uma_rp_get_gat(scopes)
			logger(:log_msg => "Invalid value for scopes argument.") if(!scopes.kind_of? Array)
			@command = 'uma_rp_get_gat'
			@params = {
				"oxd_id" => @configuration.oxd_id,
				"scopes" => scopes
	        }
	        request
	        logger(:log_msg => "Invalid GAT recieved : #{getResponseData['rpt']}") if(!getResponseData['rpt'].match(/gat_/)[0])
	        getResponseData['rpt']
		end
	end
end