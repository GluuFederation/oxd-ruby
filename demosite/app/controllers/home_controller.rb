class HomeController < ApplicationController
	skip_before_filter :verify_authenticity_token

	def index		
	end

	def setup_client
		unless(@oxdConfig.oxd_id.present?)			
			check_openid_type(@oxdConfig.op_host)

			if(@oxdConfig.dynamic_registration == false && (@oxdConfig.client_id.nil? && @oxdConfig.client_secret.nil?))				
				flash[:info] = 'Enter client ID and client Secret in oxd_config.rb file'
			else
				@oxd_command.setup_client
			end			
		end
		flash[:success] = 'Client is registered with Oxd ID : '+@oxdConfig.oxd_id
		redirect_to root_path
	end

	def get_client_token
		@oxd_command.get_client_token # Fetch protection_access_token
		redirect_to root_path
	end

	def register_site		
		if(!@oxdConfig.oxd_id.present?)			
			@oxd_command.register_site # Register site and store the returned oxd_id in config
	    end	    
	    authorization_url = @oxd_command.get_authorization_url([],[], {"param1" => "value1","param2" => "value2"})
	    redirect_to authorization_url # redirect user to obtained authorization_url to authenticate
	end

	def login
		if(@oxdConfig.oxd_id.present?)
			if (params[:code].present?)
				# pass the parameters obtained from callback url to get access_token
				@access_token = @oxd_command.get_tokens_by_code( params[:code], params[:state]) 
    		end
	        session.delete('oxd_access_token') if(session[:oxd_access_token].present?)

	        if(@oxdConfig.dynamic_registration == true)
	        	@access_token = @oxd_command.get_access_token_by_refresh_token
	        end
        	session[:oxd_access_token] = @access_token
        	session[:state] = params[:state]
        	session[:session_state] = params[:session_state]
			@user = @oxd_command.get_user_info(session[:oxd_access_token]) # pass access_token get user information from OP
			render :template => "home/index", :locals => { :user => @user }				
		end
	end

	def update_registration
		@oxdConfig.client_name = "ClienName 2"
		if(@oxd_command.update_site_registration)
			flash[:success] = 'Client settings are updated successfully!!'
		else
			flash[:error] = 'There was some error in updating Client settings'
		end
		redirect_to root_path
	end

	def logout
		# get logout url and redirect user that URL to logout from OP
		if(session[:oxd_access_token])
			@logout_url = @oxd_command.get_logout_uri(session[:state], session[:session_state])
			redirect_to @logout_url
		end	    
	end

	def clear_data
		@oxdConfig.oxd_id = ""
		@oxdConfig.client_id = "";
    	@oxdConfig.client_secret = "";
    	@oxdConfig.client_name = "";
    	@oxdConfig.protection_access_token = "";
		redirect_to root_path    	
	end
end
