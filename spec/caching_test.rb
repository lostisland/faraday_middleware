require 'test/unit'
require 'forwardable'
require 'fileutils'
require 'rack/cache'
require 'faraday'
require 'faraday_middleware/response/caching'
require 'faraday_middleware/rack_compatible'

class CachingTest < Test::Unit::TestCase
  class TestCache < Hash
    def read(key)
      if cached = self[key]
        Marshal.load(cached)
      end
    end

    def write(key, data)
      self[key] = Marshal.dump(data)
    end

    def fetch(key)
      read(key) || yield.tap { |data| write(key, data) }
    end
  end

  class Lint < Struct.new(:app)
    def call(env)
      app.call(env).on_complete do
        raise "no headers" unless env[:response_headers].is_a? Hash
        raise "no response" unless env[:response].is_a? Faraday::Response
        raise "env not identical" unless env[:response].env.object_id == env.object_id
      end
    end
  end

  def setup
    @cache = TestCache.new

    request_count = 0
    response = lambda { |env|
      [200, {'Content-Type' => 'text/plain'}, "request:#{request_count+=1}"]
    }

    @conn = Faraday.new do |b|
      b.use Lint
      b.use FaradayMiddleware::Caching, @cache
      b.adapter :test do |stub|
        stub.get('/', &response)
        stub.get('/?foo=bar', &response)
        stub.post('/', &response)
        stub.get('/other', &response)
      end
    end
  end

  extend Forwardable
  def_delegators :@conn, :get, :post

  def test_cache_get
    assert_equal 'request:1', get('/').body
    assert_equal 'request:1', get('/').body
    assert_equal 'request:2', get('/other').body
    assert_equal 'request:2', get('/other').body
  end

  def test_response_has_request_params
    get('/') # make cache
    response = get('/')
    assert_equal :get, response.env[:method]
    assert_equal '/', response.env[:url].request_uri
  end

  def test_cache_query_params
    assert_equal 'request:1', get('/').body
    assert_equal 'request:2', get('/?foo=bar').body
    assert_equal 'request:2', get('/?foo=bar').body
    assert_equal 'request:1', get('/').body
  end

  def test_doesnt_cache_post
    assert_equal 'request:1', post('/').body
    assert_equal 'request:2', post('/').body
    assert_equal 'request:3', post('/').body
  end
end

# RackCompatible + Rack::Cache
class HttpCachingTest < Test::Unit::TestCase
  include FileUtils

  CACHE_DIR = File.expand_path('../../tmp/cache', __FILE__)

  # middleware to check whether "rack.errors" is free of error reports
  class RackErrorsComplainer < Struct.new(:app)
    def call(env)
      response = app.call(env)
      error_stream = env['rack.errors'].string
      raise %(unexpected error in 'rack.errors') if error_stream.include? 'error'
      response
    end
  end

  def setup
    rm_r CACHE_DIR if File.exists? CACHE_DIR
    # force reinitializing cache dirs
    Rack::Cache::Storage.instance.clear

    request_count = 0
    response = lambda { |env|
      [200, { 'Content-Type' => 'text/plain',
              'Cache-Control' => 'public, max-age=900',
            },
            "request:#{request_count+=1}"]
    }

    @conn = Faraday.new do |b|
      b.use RackErrorsComplainer

      b.use FaradayMiddleware::RackCompatible, Rack::Cache::Context,
        :metastore   => "file:#{CACHE_DIR}/rack/meta",
        :entitystore => "file:#{CACHE_DIR}/rack/body",
        :verbose     => true

      b.adapter :test do |stub|
        stub.get('/', &response)
        stub.post('/', &response)
      end
    end
  end

  extend Forwardable
  def_delegators :@conn, :get, :post

  def test_cache_get
    response = get('/', :user_agent => 'test')
    assert_equal 'request:1', response.body
    assert_equal :get, response.env[:method]
    assert_equal 200, response.status

    response = get('/', :user_agent => 'test')
    assert_equal 'request:1', response.body
    assert_equal 'text/plain', response['content-type']
    assert_equal :get, response.env[:method]
    assert response.env[:request].respond_to?(:fetch)
    assert_equal 200, response.status

    assert_equal 'request:2', post('/').body
  end

  def test_doesnt_cache_post
    assert_equal 'request:1', get('/').body
    assert_equal 'request:2', post('/').body
    assert_equal 'request:3', post('/').body
  end
end unless defined? RUBY_ENGINE and "rbx" == RUBY_ENGINE # rbx bug #1522
