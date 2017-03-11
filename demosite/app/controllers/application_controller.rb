class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  	layout "application"
  	require 'resolv-replace'
  	require 'oxd-ruby'
  	protect_from_forgery with: :exception

 	before_filter :set_oxd_commands_instance
	protected
		def set_oxd_commands_instance
      @oxd_command = Oxd::ClientOxdCommands.new
			@uma_command = Oxd::UMACommands.new
		end  
end
