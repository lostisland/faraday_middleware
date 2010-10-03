require 'helper'

class OAuth2Test < Test::Unit::TestCase
  context 'when used' do
    setup do
      @stubs = Faraday::Adapter::Test::Stubs.new
      @stubs.get('/me?access_token=OU812') {[200, {}, 'pengwynn']}
    end

    should 'add the access token to the request' do
      do_you  = Faraday::Connection.new do |builder|
        builder.use Faraday::Request::OAuth2, 'OU812'
        builder.adapter :test, @stubs
      end
      do_you.get("/me")
    end
  end
end
