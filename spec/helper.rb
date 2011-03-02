begin
  require 'bundler/setup'
rescue LoadError
  puts 'although not required, its recommended you use bundler when running the tests'
end

require 'simplecov'
SimpleCov.start

require 'rspec'

require 'faraday_middleware'