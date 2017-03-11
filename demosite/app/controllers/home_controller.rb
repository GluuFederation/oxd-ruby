class HomeController < ApplicationController
	skip_before_filter :verify_authenticity_token  

	def index	
	end

	def register_site		
		if(!@oxd_command.getOxdId.present?)			
			@oxd_command.register_site # Register site and store the returned oxd_id in config
	    end
	    authorization_url = @oxd_command.get_authorization_url
	    redirect_to authorization_url # redirect user to obtained authorization_url to authenticate
	end

	def login
		if(@oxd_command.getOxdId.present?)
			if (params[:code].present?)
				# pass the parameters obtained from callback url to get access_token
				@access_token = @oxd_command.get_tokens_by_code( params[:code], params[:state]) 
    		end
	        session.delete('oxd_access_token') if(session[:oxd_access_token].present?)
        	session[:oxd_access_token] = @access_token
        	session[:state] = params[:state]
        	session[:session_state] = params[:session_state]
			@user = @oxd_command.get_user_info(session[:oxd_access_token]) # pass access_token get user information from OP
			render :template => "home/index", :locals => { :user => @user }				
		end
	end

	def logout
		# get logout url and redirect user that URL to logout from OP
		if(session[:oxd_access_token])
			@logout_url = @oxd_command.get_logout_uri(session[:state], session[:session_state])
			redirect_to @logout_url
		end	    
	end
end
