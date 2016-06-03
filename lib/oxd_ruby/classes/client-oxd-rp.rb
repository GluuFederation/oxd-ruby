# This class acts as mediator between ClientSocketOxdRp and ClientOxdCommands. It takes commands from ClientOxdCommands class, communicates with the ClientSocketOxdRp class and send response back to ClientOxdCommands class
# @author Inderpal Singh
# @version 2.4.3

module OxdRuby
	class ClientOxdRp < ClientSocketOxdRp		

	    # Client_oxd initialization.
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
	    		if (@command_types[i] == getCommand)
	                exist = true
	                break
	            end
	    		i += 1
	    	end
	    	if (!exist)
	    		@error_logger.info("Command: #{getCommand} does not exist! Exiting process.")
        	end
	    end

	    # send function sends the command to the oxD server.
		# Args: command (dict) - Dict representation of the JSON command string
	    def request
	    	jsondata = getData.to_json
	    	if(!is_json? (jsondata))
	    		@error_logger.info("Sending parameters must be JSON. Exiting process.")
	        end
	        length = jsondata.length
	        if( length <= 0 )
	        	@error_logger.info("Length must be more than zero. Exiting process.")
	        else
	            length = length <= 999 ? sprintf('0%d', length) : length
	        end
	        @response_json = oxd_socket_request((length + jsondata).encode("UTF-8"))
	        @response_json.sub!(@response_json[0..3], "")

	        if (@response_json)
	            object = JSON.parse(@response_json)
	            if (object['status'] == 'error') 
	            	@error_logger.info("Error : #{object['data']['error_description']}")
	            elsif (object['status'] == 'ok') 
	                @response_object = JSON.parse(@response_json)
	            end
	        else
	        	@error_logger.info("Response is empty.... Exiting process.")
	        end
	        return @response_object
	    end

	    # @return mixed
	    def getResponseData
	    	if (!getResponseObject)
	            @response_data = 'Data is empty';
	        else
	            @response_data = getResponseObject['data']
	        end
	        return @response_data
	    end

	    # @return array
	    def getData
	    	@data = {'command' => @command, 'params' => @params}
        	return @data
	    end

	    # getResponseObject function geting result from oxD server.
    	# Return: response_object - The JSON response parsing to object
    	def getResponseObject
    		return @response_object
    	end

    	# checking string format.
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