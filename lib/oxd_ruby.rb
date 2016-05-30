require "oxd_ruby/version"
require 'oxd_ruby/config'
require 'oxd_ruby/classes/client-socket-oxd-rp'

module OxdRuby
  def self.initialize_socket(base_url)
    Client_Socket_OXD_RP.new(base_url)
  end
end
