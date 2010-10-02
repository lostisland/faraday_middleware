require 'test/unit'
require 'pathname'
require 'rubygems'
require 'shoulda'
require 'faraday'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'faraday_middleware'
