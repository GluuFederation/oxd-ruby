require 'active_support/configurable'

# @author Inderpal Singh
# @note supports oxd-version 3.1.3
module Oxd

  # Configures global settings for oxd
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

  # Global settings for oxd
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
    config_accessor :client_frontchannel_logout_uris
    config_accessor :connection_type
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
    config_accessor :claims_redirect_uri
    config_accessor :op_discovery_path
    config_accessor :protection_access_token
    config_accessor :overwrite_uma_resource

    # define param_name writer
    def param_name
      config.param_name.respond_to?(:call) ? config.param_name.call : config.param_name
    end
    
    writer, line = 'def param_name=(value); config.param_name = value; end', __LINE__
    singleton_class.class_eval writer, __FILE__, line
    class_eval writer, __FILE__, line
  end

  # ****** config to hold the information about the oxd module that has been deployed (host, port, etc.) ******
  # oxd_host_ip : the host is generally localhost as all communication are carried out between oxd-ruby and oxd server using sockets.
  # oxd_host_port: the port is the one which is configured during the oxd deployment
  
  # ****** config to hold the information which are specific to website like the redirect uris ******
  # op_host: Host URL of the OpenID Provider
  # application_type: the app_type is generally 'web' although 'native' can be used for native app
  # prompt: 'login' is required if you want to force alter current user session
  # authorization_redirect_uri: [REQUIRED] Redirect uri to which user will be redirected after authorization
  # post_logout_redirect_uri: [OPTIONAL] website's public uri to call upon logout
  # client_frontchannel_logout_uris:  [REQUIRED, LIST] logout uris of the client which will be called by the OpenID provider when logout happens. This is a good place to clear session/cookies.
  # grant_types: [OPTIONAL, LIST] grant types supported by the openid server, ["authorization_code", "client_credentials"]
  # => 'client_credentials' is required for the UMA
  # acr_values: [OPTIONAL, LIST] the values are "basic" and "duo"
  # client_jwks_uri: [OPTIONAL]
  # client_token_endpoint_auth_method: [OPTIONAL]
  # client_request_uris: [OPTIONAL]
  # contacts: [OPTIONAL, LIST]
  # overwrite_uma_resource: [OPTIONAL, BOOLEAN] true - to remove existing UMA Resource and register new based on JSON Document, if false then resource protection command will fail with error uma_protection_exists
  
  # default values for config
  configure do |config|
  	config.oxd_host_ip = '127.0.0.1' 
  	config.oxd_host_port = 8099 
    config.op_host = "https://gluu.example.com"
    config.application_type = "web"
  	config.prompt = "login"
  	config.authorization_redirect_uri = "https://gluu.example.com/callback"
  	config.post_logout_redirect_uri = "https://gluu.example.com/logout"
  	config.client_frontchannel_logout_uris = ["https://gluu.example.com/callback"]
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
    config.claims_redirect_uri = []
    config.op_discovery_path = ""
    config.protection_access_token = ""
    config.dynamic_registration = true
    config.connection_type = 'local'
    config.overwrite_uma_resource = false
  end 
end
