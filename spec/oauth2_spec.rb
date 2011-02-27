require File.expand_path('../helper', __FILE__)

describe Faraday::Request::OAuth2 do
  context 'when used' do
    before do
      @stubs = Faraday::Adapter::Test::Stubs.new
      @connection = Faraday::Connection.new do |builder|
        builder.use Faraday::Request::OAuth2, '1234'
        builder.adapter :test, @stubs
      end
    end

    it 'should add the access token to the request' do
      @stubs.get('/me?access_token=1234') {[200, {}, 'sferik']}
      me = @connection.get("/me").body
      me.should == 'sferik'
    end
  end
end
