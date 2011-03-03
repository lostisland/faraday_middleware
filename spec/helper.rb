begin
  require 'bundler/setup'
rescue LoadError
  puts 'although not required, its recommended you use bundler when running the tests'
end

require 'simplecov'
SimpleCov.start

require 'rspec'

require 'faraday_middleware'


class DummyApp
  attr_accessor :env

  def call(env)
    @env = env
  end

  def reset
    @env = nil
  end
end