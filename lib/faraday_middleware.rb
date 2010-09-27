require 'faraday'

directory = File.expand_path(File.dirname(__FILE__))
require File.join(directory, 'faraday', 'oauth2')
require File.join(directory, 'faraday', 'multi_json')
require File.join(directory, 'faraday', 'mashify')
