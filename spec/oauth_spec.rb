require 'helper'
require 'faraday_middleware/request/oauth'
require 'uri'
require 'forwardable'

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
    app.call(faraday_env(env))
  end

  def make_app
    described_class.new(lambda{|env| env}, *Array(options))
  end

  context "invalid options" do
    let(:options) { nil }

    it "errors out" do
      expect{ make_app }.to raise_error(ArgumentError)
    end
  end

  context "empty options" do
    let(:options) { [{}] }

    it "signs request" do
      auth = auth_values(perform)
      expected_keys = %w[ oauth_nonce
                          oauth_signature oauth_signature_method
                          oauth_timestamp oauth_version ]

      expect(auth.keys).to match_array expected_keys
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

      expect(auth.keys).to match_array expected_keys
      expect(auth['oauth_version']).to eq(%("1.0"))
      expect(auth['oauth_signature_method']).to eq(%("HMAC-SHA1"))
      expect(auth['oauth_consumer_key']).to eq(%("CKEY"))
      expect(auth['oauth_token']).to eq(%("TOKEN"))
    end

    it "doesn't override existing header" do
      request = perform({}, "Authorization" => "iz me!")
      expect(auth_header(request)).to eq("iz me!")
    end

    it "can override oauth options per-request" do
      auth = auth_values(perform(:consumer_key => 'CKEY2'))

      expect(auth['oauth_consumer_key']).to eq(%("CKEY2"))
      expect(auth['oauth_token']).to eq(%("TOKEN"))
    end

    it "can turn off oauth signing per-request" do
      expect(auth_header(perform(false))).to be_nil
    end
  end

  context "configured without token" do
    let(:options) { [{ :consumer_key => 'CKEY', :consumer_secret => 'CSECRET' }] }

    it "adds auth info to the header" do
      auth = auth_values(perform)
      expect(auth).to include('oauth_consumer_key')
      expect(auth).not_to include('oauth_token')
    end
  end

  context "handling body parameters" do
    let(:options) { [{ :consumer_key => 'CKEY',
                       :consumer_secret => 'CSECRET',
                       :nonce => '547fed103e122eecf84c080843eedfe6',
                       :timestamp => '1286830180'}] }

    let(:value) { {'foo' => 'bar'} }

    let(:type_json) { {'Content-Type' => 'application/json'} }
    let(:type_form) { {'Content-Type' => 'application/x-www-form-urlencoded'} }

    extend Forwardable
    query_method = :build_nested_query
    query_module = ::Faraday::Utils.respond_to?(query_method) ? 'Faraday::Utils' : 'Rack::Utils'
    def_delegator query_module, query_method

    it "does not include the body for JSON" do
      auth_header_with    = auth_header(perform({}, type_json, '{"foo":"bar"}'))
      auth_header_without = auth_header(perform({}, type_json, {}))

      expect(auth_header_with).to eq(auth_header_without)
    end

    it "includes the body parameters with form Content-Type" do
      auth_header_with    = auth_header(perform({}, type_form, {}))
      auth_header_without = auth_header(perform({}, type_form, value))

      expect(auth_header_with).not_to eq(auth_header_without)
    end

    it "includes the body parameters with an unspecified Content-Type" do
      auth_header_with    = auth_header(perform({}, {}, value))
      auth_header_without = auth_header(perform({}, type_form, value))

      expect(auth_header_with).to eq(auth_header_without)
    end

    it "includes the body parameters for form type with string body" do
      # simulates the behavior of Faraday::MiddleWare::UrlEncoded
      value = { 'foo' => ['bar', 'baz', 'wat'] }
      auth_header_hash   = auth_header(perform({}, type_form, value))
      auth_header_string = auth_header(perform({}, type_form, build_nested_query(value)))
      expect(auth_header_string).to eq(auth_header_hash)
    end

  end

end
