require 'helper'

class Multi_Json_Test < Test::Unit::TestCase
  context 'when used' do
    setup do
      @stubs = Faraday::Adapter::Test::Stubs.new
      @conn  = Faraday::Connection.new do |builder|
        builder.adapter :test, @stubs
        builder.use Faraday::Response::MultiJson
      end
    end

    context "when there is a JSON body" do
      setup do
        @stubs.get('/me') { [200, {}, "{\"name\":\"Wynn Netherland\",\"username\":\"pengwynn\"}"] }
      end

      should 'parse the body as JSON' do
        me = @conn.get("/me").body
        assert me.is_a?(Hash)
        assert_equal 'Wynn Netherland', me['name']
        assert_equal 'pengwynn', me['username']
      end
    end

    context "when the JSON body is empty" do
      setup do
        @stubs.get('/me') { [200, {}, ""] }
      end

      should 'still have the status code' do
        response = @conn.get("/me")
        assert_equal 200, response.status
      end

      should 'set body to nil' do
        response = @conn.get("/me")
        assert_equal response.body, nil
      end
    end

    context "when the JSON body is 'true'" do
      setup do
        @stubs.get('/me') { [200, {}, "true"] }
      end

      should 'still have the status code' do
        response = @conn.get("/me")
        assert_equal 200, response.status
      end

      should 'set body to nil' do
        response = @conn.get("/me")
        assert_equal response.body, true
      end
    end

    context "when the JSON body is 'false'" do
      setup do
        @stubs.get('/me') { [200, {}, "false"] }
      end

      should 'still have the status code' do
        response = @conn.get("/me")
        assert_equal 200, response.status
      end

      should 'set body to nil' do
        response = @conn.get("/me")
        assert_equal response.body, false
      end
    end

  end
end
