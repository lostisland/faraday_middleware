require 'helper'

class MashifyTest < Test::Unit::TestCase
  context 'when used' do
    setup do
      @stubs = Faraday::Adapter::Test::Stubs.new
      @conn  = Faraday::Connection.new do |builder|
        builder.adapter :test, @stubs
        builder.use Faraday::Response::ParseJson
        builder.use Faraday::Response::Mashify
      end
    end

    should 'create a Hashie::Mash from the body' do
      @stubs.get('/hash') {[200, {'content-type' => 'application/json; charset=utf-8'}, '{"name":"Wynn Netherland","username":"pengwynn"}']}
      me = @conn.get("/hash").body
      assert_equal 'Wynn Netherland', me.name
      assert_equal 'pengwynn', me.username
    end

    should 'handle arrays' do
      @stubs.get('/array') {[200, {'content-type' => 'application/json; charset=utf-8'}, '[{"username":"pengwynn"},{"username":"jnunemaker"}]']}
      us = @conn.get("/array").body
      assert_equal 'pengwynn', us.first.username
      assert_equal 'jnunemaker', us.last.username
    end

    should 'handle arrays of non-hashes' do
      @stubs.get('/array/simple') {[200, {'content-type' => 'application/json; charset=utf-8'}, "[123, 456]"]}
      values = @conn.get("/array/simple").body
      assert_equal 123, values.first
      assert_equal 456, values.last
    end
    
    should 'handle arrays of hashes and non-hashes' do
      @stubs.get('/array/simple') {[200, {'content-type' => 'application/json; charset=utf-8'}, '[123, {"username":"slainer68"}, 42]']}
      values = @conn.get("/array/simple").body
      assert_equal 123, values[0]
      assert_equal "slainer68", values[1].username
      assert_equal 42, values[2]
    end
  end
end
