# frozen_string_literal: true

require 'helper'
require 'forwardable'
require 'fileutils'
require 'rack/cache'
require 'faraday'
require 'faraday_middleware/response/caching'
require 'faraday_middleware/rack_compatible'

RSpec.describe FaradayMiddleware::Caching do
  let(:caching_lint_middleware) do
    Struct.new(:app) do
      def call(env)
        app.call(env).on_complete do
          raise 'no headers' unless env[:response_headers].is_a? Hash
          raise 'no response' unless env[:response].is_a? Faraday::Response
          # raise "env not identical" unless env[:response].env.object_id == env.object_id
        end
      end
    end
  end

  before do
    @cache = TestCache.new
    request_count = 0
    response = lambda { |_env|
      [200, { 'Content-Type' => 'text/plain' }, "request:#{request_count += 1}"]
    }
    broken = lambda { |_env|
      [500, { 'Content-Type' => 'text/plain' }, "request:#{request_count += 1}"]
    }
    @conn = Faraday.new do |b|
      b.use caching_lint_middleware
      b.use FaradayMiddleware::Caching, @cache, options
      b.adapter :test do |stub|
        stub.get('/', &response)
        stub.get('/?foo=bar', &response)
        stub.post('/', &response)
        stub.get('/other', &response)
        stub.get('/broken', &broken)
        stub.get('http://www.site-a.com/test', &response)
        stub.get('http://www.site-b.com/test', &response)
      end
    end
  end

  let(:options) { {} }

  extend Forwardable
  def_delegators :@conn, :get, :post

  it 'caches get requests' do
    expect(get('/').body).to eq('request:1')
    expect(get('/').body).to eq('request:1')
    expect(get('/other').body).to eq('request:2')
    expect(get('/other').body).to eq('request:2')
  end

  it 'includes request params in the response' do
    get('/') # make cache
    response = get('/')
    expect(response.env[:method]).to eq(:get)
    expect(response.env[:url].request_uri).to eq('/')
  end

  it 'caches requests with query params' do
    expect(get('/').body).to eq('request:1')
    expect(get('/?foo=bar').body).to eq('request:2')
    expect(get('/?foo=bar').body).to eq('request:2')
    expect(get('/').body).to eq('request:1')
  end

  it 'does not cache post requests' do
    expect(post('/').body).to eq('request:1')
    expect(post('/').body).to eq('request:2')
    expect(post('/').body).to eq('request:3')
  end

  it 'does not cache responses with invalid status code' do
    expect(get('/broken').body).to eq('request:1')
    expect(get('/broken').body).to eq('request:2')
  end

  context ':ignore_params' do
    let(:options) { { ignore_params: %w[utm_source utm_term] } }

    it 'strips ignored parameters from cache_key' do
      expect(get('/').body).to eq('request:1')
      expect(get('/?utm_source=a').body).to eq('request:1')
      expect(get('/?utm_source=a&utm_term=b').body).to eq('request:1')
      expect(get('/?utm_source=a&utm_term=b&foo=bar').body).to eq('request:2')
      expect(get('/?foo=bar').body).to eq('request:2')
    end
  end

  context ':full_key' do
    let(:options) { { full_key: true } }

    it 'use full URL as cache key' do
      expect(get('http://www.site-a.com/test').body).to eq('request:1')
      expect(get('http://www.site-b.com/test').body).to eq('request:2')
    end
  end

  context ':write_options' do
    let(:options) { { write_options: { expires_in: 9000 } } }

    it 'passes on the options when writing to the cache' do
      expect(@cache).to receive(:write).with(Digest::SHA1.hexdigest('/'),
                                             instance_of(Faraday::Response),
                                             options[:write_options])
      get('/')
    end

    context 'with no :write_options' do
      let(:options) { {} }

      it "doesn't pass a third options parameter to the cache's #write" do
        expect(@cache).to receive(:write).with(Digest::SHA1.hexdigest('/'), instance_of(Faraday::Response))
        get('/')
      end
    end
  end

  class TestCache < Hash
    def read(key)
      cached = self[key]
      return unless cached

      Marshal.load(cached)
    end

    def write(key, data, _options = nil)
      self[key] = Marshal.dump(data)
    end

    def fetch(key)
      read(key) || yield.tap { |data| write(key, data) }
    end
  end
end

# RackCompatible + Rack::Cache
RSpec.describe FaradayMiddleware::RackCompatible, 'caching' do
  include FileUtils

  CACHE_DIR = File.expand_path('../tmp/cache', __dir__)

  let(:rack_errors_complainer_middleware) do
    # middleware to check whether "rack.errors" is free of error reports
    Struct.new(:app) do
      def call(env)
        response = app.call(env)
        error_stream = env[:rack_errors]
        if error_stream.respond_to?(:string) && error_stream.string.include?('error')
          raise format(%(unexpected error in 'rack.errors': %<error>p), error: error_stream.string)
        end

        response
      end
    end
  end

  before do
    rm_r CACHE_DIR if File.exist? CACHE_DIR
    # force reinitializing cache dirs
    Rack::Cache::Storage.instance.clear

    request_count = 0
    response = lambda { |_env|
      [200,
       { 'Content-Type' => 'text/plain',
         'Cache-Control' => 'public, max-age=900' },
       "request:#{request_count += 1}"]
    }

    @conn = Faraday.new do |b|
      b.use rack_errors_complainer_middleware

      b.use FaradayMiddleware::RackCompatible, Rack::Cache::Context,
            metastore: "file:#{CACHE_DIR}/rack/meta",
            entitystore: "file:#{CACHE_DIR}/rack/body",
            verbose: true

      b.adapter :test do |stub|
        stub.get('/', &response)
        stub.post('/', &response)
      end
    end
  end

  extend Forwardable
  def_delegators :@conn, :get, :post

  it 'caches get requests' do
    response = get('/', user_agent: 'test')
    expect(response.body).to eq('request:1')
    expect(response.env[:method]).to eq(:get)
    expect(response.status).to eq(200)

    response = get('/', user_agent: 'test')
    expect(response.body).to eq('request:1')
    expect(response['content-type']).to eq('text/plain')
    expect(response.env[:method]).to eq(:get)
    expect(response.env[:request].respond_to?(:fetch)).to be true
    expect(response.status). to eq(200)

    expect(post('/').body).to eq('request:2')
  end

  it 'does not cache post requests' do
    expect(get('/').body).to eq('request:1')
    expect(post('/').body).to eq('request:2')
    expect(post('/').body).to eq('request:3')
  end
end
