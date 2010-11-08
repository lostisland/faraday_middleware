require 'helper'

class ParseTest < Test::Unit::TestCase
  context 'when used' do
    setup do
      @stubs = Faraday::Adapter::Test::Stubs.new
      @conn  = Faraday::Connection.new do |builder|
        builder.adapter :test, @stubs
        require 'rexml/document'
        builder.use Faraday::Response::Parse
      end
    end

    context "when there is a JSON body" do
      setup do
        @stubs.get('/me') {[200, {'content-type' => 'application/json; charset=utf-8'}, '{"name":"Wynn Netherland","username":"pengwynn"}']}
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
        @stubs.get('/me') {[200, {'content-type' => 'application/json; charset=utf-8'}, ""]}
      end

      should 'still have the status code' do
        response = @conn.get("/me")
        assert_equal 200, response.status
      end

      should 'set body to nil' do
        response = @conn.get("/me")
        assert_equal nil, response.body
      end
    end

    context "when the JSON body is 'true'" do
      setup do
        @stubs.get('/me') {[200, {'content-type' => 'application/json; charset=utf-8'}, "true"]}
      end

      should 'still have the status code' do
        response = @conn.get("/me")
        assert_equal 200, response.status
      end

      should 'set body to true' do
        response = @conn.get("/me")
        assert_equal true, response.body
      end
    end

    context "when the JSON body is 'false'" do
      setup do
        @stubs.get('/me') {[200, {'content-type' => 'application/json; charset=utf-8'}, "false"]}
      end

      should 'still have the status code' do
        response = @conn.get("/me")
        assert_equal 200, response.status
      end

      should 'set body to false' do
        response = @conn.get("/me")
        assert_equal false, response.body
      end
    end

    context "when there is a XML body" do
      setup do
        @stubs.get('/me') {[200, {'content-type' => 'application/xml; charset=utf-8'}, '<user><name>Erik Michaels-Ober</name><username>sferik</username></user>']}
      end

      should 'parse the body as XML' do
        me = @conn.get("/me").body['user']
        assert me.is_a?(Hash)
        assert_equal 'Erik Michaels-Ober', me['name']
        assert_equal 'sferik', me['username']
      end
    end

    context "when there is a ATOM body" do
      setup do
        @stubs.get('/me') {[200, {'content-type' => 'application/atom+xml; charset=utf-8'}, '<user><name>Erik Michaels-Ober</name><username>sferik</username></user>']}
      end

      should 'parse the body as XML' do
        me = @conn.get("/me").body['user']
        assert me.is_a?(Hash)
        assert_equal 'Erik Michaels-Ober', me['name']
        assert_equal 'sferik', me['username']
      end
    end

    context "when the XML body is empty" do
      setup do
        @stubs.get('/me') {[200, {'content-type' => 'application/xml; charset=utf-8'}, ""]}
      end

      should 'still have the status code' do
        response = @conn.get("/me")
        assert_equal 200, response.status
      end

      should 'set body to nil' do
        response = @conn.get("/me")
        assert_equal Hash.new, response.body
      end
    end

  end
end
