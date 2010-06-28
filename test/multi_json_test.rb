require 'helper'

class Multi_Json_Test < Test::Unit::TestCase
  context 'when used' do
    setup do
      @stubs = Faraday::Adapter::Test::Stubs.new
      @stubs.get('/me') { [200, {}, "{\"name\":\"Wynn Netherland\",\"username\":\"pengwynn\"}"] }
    end
    
    should 'should parse the body as JSON' do
      conn  = Faraday::Connection.new do |builder|
        builder.adapter :test, @stubs
        builder.use Faraday::Response::MultiJson
      end
      
      me = conn.get("/me").body
      assert me.is_a?(Hash)
      me['name'].should == 'Wynn Netherland'
      me['username'].should == 'pengwynn'
      
    end
    
  end
end