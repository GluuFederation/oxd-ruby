$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'oxd-ruby'
require 'oxd_test_config'
require 'socket'
require 'ipaddr'
require 'logger'
require 'net/http'
require 'json'
require 'uri'

include Oxd