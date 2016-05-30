require 'socket'
require 'ipaddr'

module OxdRuby	
	class Client_Socket_OXD_RP

		#Socket_oxd constructor
		def initialize(base_url)
			@config = OxdRuby.configure
			@error_logger ||= Logger.new("#{::Rails.root}/log/oxd-ruby.log")

			if (base_url.present?)
				@base_url = base_url
			end			
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

		# request to oxd socket
		def oxd_socket_request
			host = @config.oxd_host_ip     # The web server
			port = @config.oxd_host_port   # Default HTTP port
			path = "/index.htm"                 # The file we want 

			# This is the HTTP request we send to fetch a file
			request = "GET #{path} HTTP/1.0\r\n\r\n"

			if(!socket = TCPSocket.new(host,port) )  # Connect to server
				puts "Log Error - Client: socket::socket_connect is not connected, error"
			end
			socket.print(request)               # Send request
			response = socket.read              # Read complete response
			# Split response at first blank line into headers and body
			headers,body = response.split("\r\n\r\n", 2) 
			print body                          # And display it
		end

	end
end