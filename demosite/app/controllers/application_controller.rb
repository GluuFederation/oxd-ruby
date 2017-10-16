class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  	layout "application"
  	require 'resolv-replace'
  	require 'oxd-ruby'
  	protect_from_forgery with: :exception

 	before_filter :set_oxd_commands_instance

  # method to set the client attributes taken from user
  # It should be called before adding, updating and deleting client settings 
  def set_oxd_config_values(op_host, authorization_redirect_uri, post_logout_redirect_uri, client_name, connection_type, connection_type_value, client_id, client_secret)
    @oxdConfig.op_host = op_host if(!op_host.nil?)
    @oxdConfig.authorization_redirect_uri = authorization_redirect_uri if(!op_host.nil?)
    @oxdConfig.post_logout_redirect_uri = post_logout_redirect_uri if(!post_logout_redirect_uri.nil?)
    @oxdConfig.client_name = client_name if(!client_name.nil?)    
    @oxdConfig.connection_type = connection_type if(!connection_type.nil?)
    @oxdConfig.oxd_host = connection_type_value if(!connection_type_value.nil?)   
    @oxdConfig.client_id = client_id if(!client_id.nil?)    
    @oxdConfig.client_secret = client_secret if(!client_secret.nil?)    
  end

  # @return [Boolean] type for openID Provider type, True for dynamic and False for static openID provider
  # method to know static or dynamic openID Provider
  # This should be called after getting the URI of the OpenID Provider, Client Redirect URI, Post logout URI, oxd port values from user
  def check_openid_type(op_host)
    op_host = op_host+"/.well-known/openid-configuration"
    uri = URI.parse(op_host)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    ophost_data = response.body
    @oxdConfig.dynamic_registration = (!JSON.parse(ophost_data).key?("registration_endpoint"))? false : true
    @oxdConfig.scope = ["openid", "profile", "email"] if(@oxdConfig.dynamic_registration == false)
  end 

	protected
		def set_oxd_commands_instance
      @oxd_command = Oxd::ClientOxdCommands.new
			@uma_command = Oxd::UMACommands.new
      @oxdConfig = @oxd_command.oxdConfig
		end
end
