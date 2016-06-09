# This class acts as mediator between ClientSocketOxdRp and ClientOxdCommands. It takes command from ClientOxdCommands class, communicates with the ClientSocketOxdRp class and sends response back to the command
# @author Inderpal Singh
# @oxd-version 2.4.3

module Oxd
	class ClientOxdRp < ClientSocketOxdRp		

	    # ClientOxdRp initialization
	    def initialize
	    	@command_types = ['get_authorization_url','update_site_registration', 'get_tokens_by_code','get_user_info', 'register_site', 'get_logout_uri','get_authorization_code']
  			@command	    	
	    	@response_json
	    	@response_object
	    	@data = Hash.new
	    	@params = Hash.new
	    	@response_data = Hash.new

	    	super
	    	exist = false
	    	i = 0
	    	until i > @command_types.size
	    		if (@command_types[i] == @command)
	                exist = true
	                break
	            end
	    		i += 1
	    	end
	    	if (!exist)
	    		@logger.info("Command: #{@command} does not exist! Exiting process.")
        	end
	    end

	    # request function sends request to ClientSocketOxdRp class to communicate with oxD server using oxd_socket_request method
	    def request
	    	jsondata = getData.to_json
	    	if(!is_json? (jsondata))
	    		@logger.info("Sending parameters must be JSON. Exiting process.")
	        end
	        length = jsondata.length
	        if( length <= 0 )
	        	@logger.info("JSON data length must be more than zero. Exiting process.")
	        else
	            length = length <= 999 ? sprintf('0%d', length) : length
	        end
	        @response_json = oxd_socket_request((length + jsondata).encode("UTF-8"))
	        @response_json.sub!(@response_json[0..3], "")

	        if (@response_json)
	            response = JSON.parse(@response_json)
	            if (response['status'] == 'error') 
	            	@logger.info("Error : #{response['data']['error_description']}")
	            elsif (response['status'] == 'ok') 
	                @response_object = JSON.parse(@response_json)
	            end
	        else
	        	@logger.info("Response is empty.... Exiting process.")
	        end
	        return @response_object
	    end

	    # @return mixed
	    def getResponseData
	    	if (!@response_object)
	            @response_data = 'Data is empty';
	        else
	            @response_data = @response_object['data']
	        end
	        return @response_data
	    end

	    # @return array
	    def getData
	    	@data = {'command' => @command, 'params' => @params}
        	return @data
	    end

    	# checking string format: Must be JSON
    	# @param  String: string
    	# @return bool
 		def is_json? (string)
 			begin
		      !!JSON.parse(string)
		    rescue
		      false
		    end 			
 		end
	end
end