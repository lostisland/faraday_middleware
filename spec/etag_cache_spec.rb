require 'helper'
require 'faraday_middleware/request/etag_cache'

Faraday::Adapter::Test::Stubs.class_eval { public :new_stub }

describe FaradayMiddleware::EtagCache do
  def cache_key(path)
    [:faraday_etags, "http:#{path}"]
  end

  def etag_cached
    cache.write(cache_key("/foo"), {:body => "here", :response_headers => {"Etag" => "Foo"}})
  end

  def connection(options = middleware_options)
    Faraday.new do |c|
      c.use described_class, options
      c.adapter :test do |stub|
        yield(stub) if block_given?
      end
    end
  end

  def response(responded, method = :get)
    connection do |stub|
      stub.new_stub(method, "/foo") {
        responded
      }
    end.run_request(method, "/foo", "request data", nil)
  end

  let(:cache) { SimpleCache.new }
  let(:middleware_options) { {:cache => cache} }

  it "blows up without :cache" do
    expect{ described_class.new({}, {}) }.to raise_error(/ :cache /)
  end

  it "stores :get responses with Etag in cache" do
    response [200, {"Etag" => "x"}, "here"]
    cache.read(cache_key("/foo"))[:body].should == "here"
  end

  it "stores :head responses with Etag in cache" do
    response [200, {"Etag" => "x"}, "here"], :head
    cache.read(cache_key("/foo"))[:body].should == "here"
  end

  it "does not store responses without Etag in cache" do
    response [200, {}, "here"]
    cache.keys.should == []
  end

  it "does not store responses with weird code" do
    response [202, {"Etag" => "x"}, "here"]
    cache.read(cache_key("/foo")).should == nil
  end

  it "reads response from cache" do
    etag_cached
    response([304, {}, "Blob"]).env[:body].should == "here"
    cache.read(cache_key("/foo"))[:body].should == "here"
  end

  it "does not write read response" do
    etag_cached
    cache.should_not_receive(:write)
    response([304, {}]).env[:body].should == "here"
  end

  it "does not overwrite cache with invalid response" do
    etag_cached
    response([302, {}, "Blob"]).env[:body].should == "Blob"
    cache.read(cache_key("/foo"))[:body].should == "here"
  end

  it "sets cached etag onto request" do
    etag_cached
    response([304, {}]).env[:request_headers]["If-None-Match"].should == "Foo"
  end

  it "returns and saves updated response in cache" do
    etag_cached
    response([200, {"Etag" => "x"}, "New"]).env[:body].should == "New"
    cache.read(cache_key("/foo"))[:body].should == "New"
  end

  context "with :cache_key_prefix" do
    let(:middleware_options) { {:cache => cache, :cache_key_prefix => :foo} }

    it "stores in given cache_key" do
      response [200, {"Etag" => "x"}, "here"]
      cache.keys.should == [[:foo, "http:/foo"]]
    end
  end
end
