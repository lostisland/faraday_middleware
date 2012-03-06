require 'helper'
require 'faraday_middleware/request/oauth'
require 'uri'

describe FaradayMiddleware::OAuth do
  def auth_header(env)
    env[:request_headers]['Authorization']
  end

  def auth_values(env)
    if auth = auth_header(env)
      raise "invalid header: #{auth.inspect}" unless auth.sub!('OAuth ', '')
      Hash[*auth.split(/, |=/)]
    end
  end

  def perform(oauth_options = {}, headers = {}, params = {})
    env = {
      :url => URI('http://example.com/'),
      :request_headers => Faraday::Utils::Headers.new.update(headers),
      :request => {},
      :body => params
    }
    unless oauth_options.is_a? Hash and oauth_options.empty?
      env[:request][:oauth] = oauth_options
    end
    app = make_app
    app.call(env)
  end

  def make_app
    described_class.new(lambda{|env| env}, *Array(options))
  end

  context "invalid options" do
    let(:options) { nil }

    it "should error out" do
      expect { make_app }.to raise_error(ArgumentError)
    end
  end

  context "empty options" do
    let(:options) { [{}] }

    it "should sign request" do
      auth = auth_values(perform)
      expected_keys = %w[ oauth_nonce
                          oauth_signature oauth_signature_method
                          oauth_timestamp oauth_version ]

      auth.keys.should =~ expected_keys
    end
  end

  context "configured with consumer and token" do
    let(:options) do
      [{ :consumer_key => 'CKEY', :consumer_secret => 'CSECRET',
         :token => 'TOKEN', :token_secret => 'TSECRET'
      }]
    end

    it "adds auth info to the header" do
      auth = auth_values(perform)
      expected_keys = %w[ oauth_consumer_key oauth_nonce
                          oauth_signature oauth_signature_method
                          oauth_timestamp oauth_token oauth_version ]

      auth.keys.should =~ expected_keys
      auth['oauth_version'].should eq(%("1.0"))
      auth['oauth_signature_method'].should eq(%("HMAC-SHA1"))
      auth['oauth_consumer_key'].should eq(%("CKEY"))
      auth['oauth_token'].should eq(%("TOKEN"))
    end

    it "doesn't override existing header" do
      request = perform({}, "Authorization" => "iz me!")
      auth_header(request).should eq("iz me!")
    end

    it "can override oauth options per-request" do
      auth = auth_values(perform(:consumer_key => 'CKEY2'))

      auth['oauth_consumer_key'].should eq(%("CKEY2"))
      auth['oauth_token'].should eq(%("TOKEN"))
    end

    it "can turn off oauth signing per-request" do
      auth_header(perform(false)).should be_nil
    end
  end

  context "configured without token" do
    let(:options) { [{ :consumer_key => 'CKEY', :consumer_secret => 'CSECRET' }] }

    it "adds auth info to the header" do
      auth = auth_values(perform)
      auth.should include('oauth_consumer_key')
      auth.should_not include('oauth_token')
    end
  end

  context "handling body parameters" do
    let(:options) { [{ :consumer_key => 'CKEY', 
                       :consumer_secret => 'CSECRET',
                       :nonce => '547fed103e122eecf84c080843eedfe6',
                       :timestamp => '1286830180'}] }

    it "does not include the body with a Content-Type that is not application/x-www-form-urlencoded" do
      value = { 'foo' => 'bar' }
      auth_header_with    = auth_header(perform({}, { 'Content-Type' => 'application/json' }, JSON.dump(value)))
      auth_header_without = auth_header(perform({}, { 'Content-Type' => 'application/json' }, {}))

      auth_header_with.should == auth_header_without
    end

    it "includes the body parameters with Content-Type application/x-www-form-urlencoded" do
      value = { 'foo' => 'bar' }
      auth_header_with    = auth_header(perform({}, { 'Content-Type' => 'application/x-www-form-urlencoded' }, {}))
      auth_header_without = auth_header(perform({}, { 'Content-Type' => 'application/x-www-form-urlencoded' }, value))

      auth_header_with.should_not == auth_header_without
    end

    it "includes the body parameters with an unspecified Content-Type" do
      value = { 'foo' => 'bar' }
      auth_header_with    = auth_header(perform({}, {}, value))
      auth_header_without = auth_header(perform({}, { 'Content-Type' => 'application/x-www-form-urlencoded' }, value))

      auth_header_with.should == auth_header_without
    end

    it "includes the body parameters with Content-Type application/x-www-form-urlencoded and a string body" do
      value = { 'foo' => 'bar' }
      auth_header_hash =   auth_header(perform({}, { 'Content-Type' => 'application/x-www-form-urlencoded' }, value))
      auth_header_string = auth_header(perform({}, { 'Content-Type' => 'application/x-www-form-urlencoded' }, Faraday::Utils.build_query(value)))
      auth_header_string.should == auth_header_hash
    end

    it "includes the body parameters with Content-Type application/x-www-form-urlencoded and a string body with nested params" do
      # simulates the behavior of Faraday::MiddleWare::UrlEncoded
      value = { 'foo' => ['bar', 'baz', 'wat'] }
      auth_header_hash =   auth_header(perform({}, { 'Content-Type' => 'application/x-www-form-urlencoded' }, value))
      auth_header_string = auth_header(perform({}, { 'Content-Type' => 'application/x-www-form-urlencoded' }, Faraday::Utils.build_nested_query(value)))
      auth_header_string.should == auth_header_hash
    end

  end

end
