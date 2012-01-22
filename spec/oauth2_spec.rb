require 'helper'
require 'uri'
require 'faraday_middleware/request/oauth2'
require 'faraday/utils'

describe FaradayMiddleware::OAuth2 do

  def query_params(env)
    Faraday::Utils.parse_query env[:url].query
  end

  def auth_header(env)
    env[:request_headers]['Authorization']
  end

  def perform(params = {}, headers = {})
    env = {
      :url => URI('http://example.com/?' + Faraday::Utils.build_query(params)),
      :request_headers => Faraday::Utils::Headers.new.update(headers)
    }
    app = make_app
    app.call(env)
  end

  def make_app
    described_class.new(lambda{|env| env}, *Array(options))
  end

  context "no token configured" do
    let(:options) { nil }

    it "doesn't add params" do
      request = perform(:q => 'hello')
      query_params(request).should eq('q' => 'hello')
    end

    it "doesn't add headers" do
      auth_header(perform).should be_nil
    end

    it "creates header for explicit token" do
      request = perform(:q => 'hello', :access_token => 'abc123')
      query_params(request).should eq('q' => 'hello', 'access_token' => 'abc123')
      auth_header(request).should eq(%(Token token="abc123"))
    end
  end

  context "default token configured" do
    let(:options) { 'XYZ' }

    it "adds token param" do
      query_params(perform(:q => 'hello')).should eq('q' => 'hello', 'access_token' => 'XYZ')
    end

    it "adds token header" do
      auth_header(perform).should eq(%(Token token="XYZ"))
    end

    it "overrides default with explicit token" do
      request = perform(:q => 'hello', :access_token => 'abc123')
      query_params(request).should eq('q' => 'hello', 'access_token' => 'abc123')
      auth_header(request).should eq(%(Token token="abc123"))
    end

    it "clears default with empty explicit token" do
      request = perform(:q => 'hello', :access_token => nil)
      query_params(request).should eq('q' => 'hello', 'access_token' => nil)
      auth_header(request).should be_nil
    end
  end

  context "existing Authorization header" do
    let(:options) { 'XYZ' }
    subject { perform({:q => 'hello'}, 'Authorization' => 'custom') }

    it "adds token param" do
      query_params(subject).should eq('q' => 'hello', 'access_token' => 'XYZ')
    end

    it "doesn't override existing header" do
      auth_header(subject).should eq('custom')
    end
  end

  context "custom param name configured" do
    let(:options) { ['XYZ', {:param_name => :oauth}] }

    it "adds token param" do
      query_params(perform).should eq('oauth' => 'XYZ')
    end

    it "overrides default with explicit token" do
      request = perform(:oauth => 'abc123')
      query_params(request).should eq('oauth' => 'abc123')
      auth_header(request).should eq(%(Token token="abc123"))
    end
  end

  context "options without token configuration" do
    let(:options) { [{:param_name => :oauth}] }

    it "doesn't add param" do
      query_params(perform).should be_empty
    end

    it "overrides default with explicit token" do
      query_params(perform(:oauth => 'abc123')).should eq('oauth' => 'abc123')
    end
  end

  context "invalid param name configured" do
    let(:options) { ['XYZ', {:param_name => nil}] }

    it "raises error" do
      expect { make_app }.to raise_error(ArgumentError, ":param_name can't be blank")
    end
  end
end
