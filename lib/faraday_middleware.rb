require 'faraday'

directory = File.expand_path(File.dirname(__FILE__))
require File.join(directory, 'faraday', 'oauth2')

module FaradayMiddleware
  
  VERSION = "0.0.1".freeze
  
end