require 'helper'

class OAuthTest < Test::Unit::TestCase
  context 'when used' do
    setup do
      @stubs = Faraday::Adapter::Test::Stubs.new
      @stubs.get('/me') { [200, {}, 'pengwynn'] }
      
    end

    should 'add the access token to the request' do
      do_you  = Faraday::Connection.new do |builder|
        builder.use Faraday::Request::OAuth, 'OU812', 'vh5150', '8675309', '8008135'
        builder.adapter :test, @stubs
      end
      resp = do_you.get("/me")
      
    end
  end
end
