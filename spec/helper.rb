if ENV['COVERAGE']
  require 'simplecov'

  SimpleCov.formatter = Class.new do
    def format(result)
      SimpleCov::Formatter::HTMLFormatter.new.format(result) unless ENV['CI']
      File.open('coverage/covered_percent', 'w') do |f|
        f.puts result.source_files.covered_percent.to_i
      end
    end
  end

  SimpleCov.start do
    # add_filter 'faraday_middleware.rb'
    add_filter 'backwards_compatibility.rb'
  end
end

require 'rspec'

module ResponseMiddlewareExampleGroup
  def self.included(base)
    base.let(:options) { Hash.new }
    base.let(:headers) { Hash.new }
    base.let(:middleware) {
      described_class.new(lambda {|env|
        Faraday::Response.new(env)
      }, options)
    }
  end

  def process(body, content_type = nil, options = {})
    env = {
      :body => body, :request => options,
      :response_headers => Faraday::Utils::Headers.new(headers)
    }
    env[:response_headers]['content-type'] = content_type if content_type
    middleware.call(env)
  end
end

class SimpleCache
  def initialize
    @cache = {}
  end

  def read(key)
    @cache[key]
  end

  def write(key, value, options={})
    if not options[:unless_exist] or not @cache[key]
      @cache[key] = value
    end
  end

  def fetch(key, options={})
    result = read(key)
    return result if result
    result = yield
    write(key, result)
  end

  def keys
    @cache.keys
  end
end

RSpec.configure do |config|
  config.include ResponseMiddlewareExampleGroup, :type => :response
end
