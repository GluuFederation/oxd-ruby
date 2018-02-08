require 'active_support/configurable'

# @author Inderpal Singh
# @note supports oxd-version 3.1.1
module Oxd

  # Configures global settings for Oxd
  # @yield config
  # @example
  #   Oxd.configure do |config|
  #     config.oxd_host_ip = '127.0.0.1'
  #   end
  def self.configure(&block)
    @config ||= Oxd::Configuration.new
    if block_given?
      yield(@config)
    end
  end

  # Global settings for Oxd
  def self.config
    @config
  end

  # This class holds all the information about the client and the OP metadata
  class Configuration
    include ActiveSupport::Configurable    
    config_accessor :oxd_host_ip
    config_accessor :oxd_host_port    
    config_accessor :op_host
    config_accessor :client_id
    config_accessor :client_secret
    config_accessor :client_name
    config_accessor :authorization_redirect_uri
    config_accessor :logout_redirect_uri
    config_accessor :post_logout_redirect_uri
    config_accessor :scope
    config_accessor :grant_types
    config_accessor :application_type
    config_accessor :response_types
    config_accessor :acr_values
    config_accessor :client_jwks_uri
    config_accessor :client_token_endpoint_auth_method
    config_accessor :client_request_uris
    config_accessor :contacts
    config_accessor :client_logout_uris
    config_accessor :connection_type
    config_accessor :oxd_host
    config_accessor :dynamic_registration
    config_accessor :prompt
    config_accessor :id_token
    config_accessor :refresh_token
    config_accessor :oxd_id
    config_accessor :ticket
    config_accessor :rpt
    config_accessor :client_sector_identifier_uri
    config_accessor :ui_locales
    config_accessor :claims_locales
    config_accessor :protection_access_token

    # define param_name writer
    def param_name
      config.param_name.respond_to?(:call) ? config.param_name.call : config.param_name
    end
    
    writer, line = 'def param_name=(value); config.param_name = value; end', __LINE__
    singleton_class.class_eval writer, __FILE__, line
    class_eval writer, __FILE__, line
  end

  #[oxd]
  # oxd_host_ip : the host is generally localhost as all communication are carried out between oxd-ruby and oxd server using sockets.
  # oxd_host_port: the port is the one which is configured during the oxd deployment
  
  #[client]
  # application_type: the app_type is generally 'web' although 'native' can be used for native app
  # authorization_redirect_uri: [REQUIRED] this is the primary redirect URL of the website or app
  # => the first one is always your primary uri set in authorization_redirect_uri
  # post_logout_redirect_uri: [OPTIONAL] website's public uri to call upon logout
  # client_logout_uris:  [REQUIRED, LIST] logout uris of the client
  # grant_types: [OPTIONAL, LIST] grant types to "authorization_code" or "refresh_token"
  # acr_values: [OPTIONAL, LIST] the values are "basic" and "duo"
  # client_jwks_uri: [OPTIONAL]
  # client_token_endpoint_auth_method: [OPTIONAL]
  # client_request_uris: [OPTIONAL]
  # contacts: [OPTIONAL, LIST]
  
  # default values for config
  configure do |config|
  	config.oxd_host_ip = '127.0.0.1' 
  	config.oxd_host_port = 8099 
    config.op_host = "https://gluu.example.com"
    config.application_type = "web"
  	config.prompt = "login"
  	config.authorization_redirect_uri = "https://gluu.example.com/callback"
  	config.post_logout_redirect_uri = "https://gluu.example.com/logout"
  	config.client_logout_uris = ["https://gluu.example.com/callback"]
  	config.logout_redirect_uri = 'https://gluu.example.com/logout'
  	config.grant_types = []
  	config.acr_values = ["basic"]
  	config.client_jwks_uri = ""
  	config.client_token_endpoint_auth_method = ""
  	config.client_request_uris = []
  	config.scope = ["openid", "profile", "email", "uma_protection","uma_authorization"]
  	config.contacts = ["example-email@gmail.com"]
  	config.response_types = ["code"]
    config.oxd_id = ""
    config.id_token = ""
    config.client_name = ""
    config.client_sector_identifier_uri = ""
    config.ui_locales = []
    config.claims_locales = []
    config.protection_access_token = ""
    config.oxd_host = ""
    config.dynamic_registration = true
    config.connection_type = 'local'
  end 
end
