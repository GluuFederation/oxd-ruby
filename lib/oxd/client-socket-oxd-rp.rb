# A class which takes care of the socket communication with oxD Server.
# @author Inderpal Singh
# @oxd-version 2.4.3

require 'socket'
require 'ipaddr'

module Oxd	
	class ClientSocketOxdRp
		
		#ClientSocketOxdRp initialization
		def initialize
			@configuration = Oxd.config

			# Initialize Log file
			# Location : app_root/log/oxd-ruby.log
			@logger ||= Logger.new("#{::Rails.root}/log/oxd-ruby.log")

			if !@configuration.authorization_redirect_uri.present?
				@logger.info("Oxd configuration test: Error problem with json data.")
			end
			if (IPAddr.new(@configuration.oxd_host_ip) rescue nil).nil?
				@logger.info("#{@configuration.oxd_host_ip} is not a valid IP address")
			end
			if !@configuration.oxd_host_port.is_a?(Integer) && @configuration.oxd_host_port < 0 && @configuration.oxd_host_port > 65535
				@logger.info("#{@configuration.oxd_host_port} is not a valid port for socket. Port must be integer and between from 0 to 65535")
			end	
		end

		# oxd_socket_request function sends the command to the oxD server and recieves the response.
		# Args:
        # => request - representation of the JSON command string
		# Returns:
		# => response - The JSON response from the oxD Server
		def oxd_socket_request(request, char_count = 8192)
			@configuration = Oxd.config
			host = @configuration.oxd_host_ip     # The web server
			port = @configuration.oxd_host_port   # Default HTTP port

			if(!socket = TCPSocket.new(host,port) )  # Connect to Oxd server
				@logger.info("Client: socket::socket_connect is not connected")
			else
				@logger.info("Client: socket::socket_connect connected : #{request}")
			end
			
			socket.print(request)               # Send request
			response = socket.recv(char_count)  # Read response
			if(response)
	            @logger.info("Client: oxd_socket_response: #{response}")
	        else
	            @logger.info("Client: oxd_socket_response : Error socket reading process.")
	        end
	        # close connection
	        if(socket.close)
	          @logger.info("Client: oxd_socket_connection : disconnected.")
	        end
	        return response
		end
	end
end