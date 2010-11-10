require 'simplecov'
SimpleCov.start do
  add_group 'Libraries', 'lib'
end

require 'test/unit'
require 'shoulda'

require File.expand_path('../../lib/faraday_middleware', __FILE__)
