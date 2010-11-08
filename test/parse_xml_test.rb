require 'helper'

class ParseXmlTest < Test::Unit::TestCase
  context 'when used' do
    setup do
      @stubs = Faraday::Adapter::Test::Stubs.new
      @conn  = Faraday::Connection.new do |builder|
        builder.adapter :test, @stubs
        builder.use Faraday::Response::ParseXml
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
