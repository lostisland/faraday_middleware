require 'helper'
require 'faraday_middleware/request/signature'

describe FaradayMiddleware::Signature do
  let(:middleware) { described_class.new(lambda{|env| env}, 'key', 'secret') }

  def process(body)
    middleware.call({
      :body => body,
      :method => :post,
      :url => URI('http://example.com/resource')
    })
  end

  def auth_hash(params, key = 'key', secret = 'secret')
    Signature::Request.new('POST', '/resource', params).sign(Signature::Token.new(key, secret))
  end

  it "doesn't change nil body" do
    process(nil)[:body].should be_nil
  end

  it "doesn't change empty body" do
    process('')[:body].should be_empty
  end

  it "doesn't change string body" do
    process('foo')[:body].should eql('foo')
  end

  context "signing a hash" do
    let(:params) { { 'test' => 'value' } }

    before(:each) do
      Time.stub(:now).and_return(Time.at(1))
    end

    it "signs a body hash" do
      process(params)[:body].should eql(params.merge(auth_hash(params)))
    end

    it "signs an empty body hash" do
      process({})[:body].should eql({}.merge(auth_hash({})))
    end

    it "uses the key" do
      process(params)[:body].should_not eql(params.merge(auth_hash(params, 'badkey', 'secret')))
    end

    it "uses the secret" do
      process(params)[:body].should_not eql(params.merge(auth_hash(params, 'key', 'badsecret')))
    end

  end
end

