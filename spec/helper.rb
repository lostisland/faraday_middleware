if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start do
    # add_filter 'faraday_middleware.rb'
    add_filter 'backwards_compatibility.rb'
  end
end

require 'rspec'
