# A class which takes care of the socket communication with oxD Server.
# @author Inderpal Singh
# @version 2.4.3

require 'socket'
require 'ipaddr'

module OxdRuby	
	class ClientSocketOxdRp
		
		#Socket_oxd constructor
		def initialize
			@config = OxdRuby.configuration		

			# Initialize Error Log file
			# Location : app_root/log/oxd-ruby.log
			@error_logger ||= Logger.new("#{::Rails.root}/log/oxd-ruby.log")

			if !@config.authorization_redirect_uri.present?
				@error_logger.info("oxd-configuration-test: Error problem with json data.")
			end
			if (IPAddr.new(@config.oxd_host_ip) rescue nil).nil?
				@error_logger.info("#{@config.oxd_host_ip} is not a valid IP address")
			end
			if !@config.oxd_host_port.is_a?(Integer) && @config.oxd_host_port < 0 && @config.oxd_host_port > 65535
				@error_logger.info("#{@config.oxd_host_port} is not a valid port for socket. Port must be integer and between from 0 to 65535")
			end	
		end

		# oxd_socket_request function sends the command to the oxD server and recieves the response.
		# Args:
        # => request - representation of the JSON command string
		# Returns:
		# => response - The JSON response from the oxD Server
		def oxd_socket_request(request, char_count = 8192)
			@config = OxdRuby.configuration
			host = @config.oxd_host_ip     # The web server
			port = @config.oxd_host_port   # Default HTTP port

			if(!socket = TCPSocket.new(host,port) )  # Connect to Oxd server
				@error_logger.info("Client: socket::socket_connect is not connected")
			else
				@error_logger.info("Client: socket::socket_connect connected : #{request}")
			end
			
			socket.print(request)               # Send request
			response = socket.recv(char_count)  # Read response
			if(response)
	            @error_logger.info("Client: oxd_socket_response: #{response}")
	        else
	            @error_logger.info("Client: oxd_socket_response : Error socket reading process.")
	        end
	        # close connection
	        if(socket.close)
	          @error_logger.info("Client: oxd_socket_connection : disconnected.")
	        end
	        return response
		end
	end
end