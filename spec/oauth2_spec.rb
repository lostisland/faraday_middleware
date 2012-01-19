require 'helper'
require 'uri'
require 'faraday_middleware/request/oauth2'

describe FaradayMiddleware::OAuth2 do

  def query_params(request)
    Faraday::Utils.parse_query request[:url].query
  end

  context 'when used with a access token in the initializer' do
    let(:oauth2) { described_class.new(lambda{|env| env}, '1234') }

    it 'should add the access token to the request' do
      env = {
        :request_headers => {},
        :url => URI('http://www.github.com')
      }

      request = oauth2.call(env)
      request[:request_headers]["Authorization"].should == "Token token=\"1234\""
      query_params(request)["access_token"].should == "1234"
    end
  end

  context 'when used with a access token in the query_values' do
    let(:oauth2) { described_class.new(lambda{|env| env}) }

    it 'should add the access token to the request' do
      env = {
        :request_headers => {},
        :url => URI('http://www.github.com/?access_token=1234')
      }

      request = oauth2.call(env)
      request[:request_headers]["Authorization"].should == "Token token=\"1234\""
      query_params(request)["access_token"].should == "1234"
    end
  end

  context 'integration test' do
    let(:stubs) { Faraday::Adapter::Test::Stubs.new }
    let(:connection) do
      Faraday::Connection.new do |builder|
        builder.use described_class, '1234'
        builder.adapter :test, stubs
      end
    end

    it 'should add the access token to the query string' do
      stubs.get('/me?access_token=1234') {[200, {}, 'sferik']}
      me = connection.get('/me')
      me.body.should == 'sferik'
    end
  end
end
