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
      @stubs.get('/hash') {[200, {}, '{"name":"Wynn Netherland","username":"pengwynn"}']}
      me = @conn.get("/hash").body
      assert_equal 'Wynn Netherland', me.name
      assert_equal 'pengwynn', me.username
    end

    should 'handle arrays' do
      @stubs.get('/array') {[200, {}, '[{"username":"pengwynn"},{"username":"jnunemaker"}]']}
      us = @conn.get("/array").body
      assert_equal 'pengwynn', us.first.username
      assert_equal 'jnunemaker', us.last.username
    end

    should 'handle arrays of non-hashes' do
      @stubs.get('/array/simple') {[200, {}, "[123, 456]"]}
      values = @conn.get("/array/simple").body
      assert_equal 123, values.first
      assert_equal 456, values.last
    end
  end
end
