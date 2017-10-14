require 'socket'
require 'ipaddr'
require 'net/http'
require 'json'
require 'uri'

# @author Inderpal Singh
# @note supports oxd-version 3.1.1
module Oxd

	# A class which takes care of the socket communication with oxD Server.
	class OxdConnector

	    # class constructor
	    def initialize
  			@command	    	
	    	@response_json
	    	@response_object
	    	@data = Hash.new
	    	@params = Hash.new
	    	@response_data = Hash.new
	    	@configuration = Oxd.config

			logger(:log_msg => "Problem with json data : authorization_redirect_uri can't be blank") if @configuration.authorization_redirect_uri.empty?
			logger(:log_msg => "#{@configuration.oxd_host_ip} is not a valid IP address") if (IPAddr.new(@configuration.oxd_host_ip) rescue nil).nil?
			logger(:log_msg => "#{@configuration.oxd_host_port} is not a valid port for socket. Port must be integer and between from 0 to 65535") if (!@configuration.oxd_host_port.is_a?(Integer) || (@configuration.oxd_host_port < 0 && @configuration.oxd_host_port > 65535))	
	    end

	    # Checks the validity of command that is to be passed to oxd-server
	    def validate_command
	    	command_types = ['setup_client', 'get_client_token', 'get_authorization_url','update_site_registration','get_tokens_by_code','get_access_token_by_refresh_token', 'get_user_info', 'register_site', 'get_logout_uri','get_authorization_code','uma_rs_protect','uma_rs_check_access','uma_rp_get_rpt','uma_rp_get_claims_gathering_url']
	    	if (!command_types.include?(@command))
				logger(:log_msg => "Command: #{@command} does not exist! Exiting process.")
        	end
	    end

		# method to communicate with the oxD server
		# @param request [JSON] representation of the JSON command string
		# @param char_count [Integer] number of characters to read from response
		# @return response from the oxD Server
		def oxd_socket_request(request, char_count = 8192)
			host = @configuration.oxd_host_ip     # The web server
			port = @configuration.oxd_host_port   # Default HTTP port

			if(!socket = TCPSocket.new(host, port) )  # Connect to Oxd server
				logger(:log_msg => "Socket Error : Couldn't connect to socket ")
			else
				logger(:log_msg => "Client: socket::socket_connect connected : #{request}", :error => "")
			end
			
			socket.print(request)               # Send request
			response = socket.recv(char_count)  # Read response
			if(response)
				logger(:log_msg => "Client: oxd_socket_response: #{response}", :error => "")
	        else
				logger(:log_msg => "Client: oxd_socket_response : Error socket reading process.")
	        end
	        # close connection
	        if(socket.close)
	        	logger(:log_msg => "Client: oxd_socket_connection : disconnected.", :error => "")
	        end
	        #logger(:log_msg => response)
			#abort
	        return response
		end
		
		# method to communicate with the oxD-to-http server
		# @param request_params [JSON] representation of the JSON command string
		# @return response from the oxD-to-http server
		def oxd_http_request(request_params, command = "")
			uri = URI.parse("https://127.0.0.1/"+command)
			http = Net::HTTP.new("127.0.0.1", 8443)
			http.use_ssl = true
			http.verify_mode = OpenSSL::SSL::VERIFY_NONE
			request = Net::HTTP::Post.new(uri.request_uri)

			request.add_field('Content-Type', 'application/json')

			if(@configuration.protection_access_token.present?)
				request.add_field('Authorization','Bearer '+@configuration.protection_access_token)
			end
			request.body = request_params
			logger(:log_msg => "Sending oxd_http_request command #{command} with data #{request_params.inspect}", :error => "")
			response = http.request(request)
			response2 = response.body
			logger(:log_msg => "oxd_http_request response #{response2}", :error => "")
			return response2
		end

		# @param comm [String] command string for oxd-to-http
		# method to send commands to the oxD server and oxd-to-http and to recieve the response via {#oxd_socket_request}
		# @return [JSON] @response_object : response from the oxd server in JSON form
	    def request(comm = "")
			
	    	uri = URI.parse(@configuration.authorization_redirect_uri)	
			logger(:log_msg => "Please enable SSL on your website or check URIs in Oxd configuration.") if (uri.scheme != 'https')
	    	validate_command
	    	
	    	if(@configuration.connection_type == 'local')
				jsondata = getData.to_json
				if(!is_json? (jsondata))
					logger(:log_msg => "Sending parameters must be JSON. Exiting process.")
				end
				length = jsondata.length
				if( length <= 0 )
					logger(:log_msg => "JSON data length must be more than zero. Exiting process.")
				else
					length = length <= 999 ? sprintf('0%d', length) : length
				end
				@response_json = oxd_socket_request((length.to_s + jsondata).encode("UTF-8"))
				@response_json.sub!(@response_json[0..3], "")
	        else
				jsondata = getData2.to_json
				@response_json = oxd_http_request(jsondata, comm)
	        end


	        if (@response_json)
	            response = JSON.parse(@response_json)
	            if (response['status'] == 'error') 
	    			logger(:log_msg => "OxD Server Error : #{response['data']['error_description']}")
	            elsif (response['status'] == 'ok')
					
	                @response_object = JSON.parse(@response_json)
	            end
	        else
	        	logger(:log_msg => "Response is empty. Exiting process.")
	        end
	        
	        return @response_object
	    end

		# @return [Mixed] @response_object set by request method
	    def getResponseObject
	    	return @response_object
	    end

	    # extracts 'data' parameter from @response_object
	    # @return [Mixed] @response_data
	    def getResponseData
	    	if (!@response_object)
	            @response_data = 'Data is empty';
	        else
	            @response_data = @response_object['data']
	        end
	        return @response_data
	    end

	    # combines command and command parameters for socket request
	    # @return [Array] @data
	    def getData
	    	@data = {'command' => @command, 'params' => @params}
        	return @data
	    end
	    
	    def getData2
	    	@data = @params
        	return @data
	    end

    	# checks whether the passed string is in JSON format or not
    	# @param  string_to_validate [String]
    	# @return [Boolean]
 		def is_json? (string_to_validate)
 			begin
		      !!JSON.parse(string_to_validate)
		    rescue
		      false
		    end 			
 		end

 		# Logs server response and errors to log file
 		# @param args [Hash] {:log_msg, :error} response to print in log file and raise error
 		# @raise RuntimeError
 		def logger(args={})
 			# Initialize Log file
			# Location : app_root/log/oxd-ruby.log
			@logger ||= Logger.new("log/oxd-ruby.log")
			@logger.info(args[:log_msg])

			raise (args[:error] || args[:log_msg]) if args[:error] != ""
		end		
	end
end
