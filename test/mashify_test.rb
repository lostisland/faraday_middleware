require 'helper'

class MashifyTest < Test::Unit::TestCase
  context 'when used' do
    setup do
      @stubs = Faraday::Adapter::Test::Stubs.new
      @conn  = Faraday::Connection.new do |builder|
        builder.adapter :test, @stubs
        builder.use Faraday::Response::MultiJson
        builder.use Faraday::Response::Mashify
      end
    end

    should 'create a Hashie::Mash from the body' do
      @stubs.get('/hash') { [200, {}, "{\"name\":\"Wynn Netherland\",\"username\":\"pengwynn\"}"] }
      me = @conn.get("/hash").body
      me.name.should == 'Wynn Netherland'
      me.username.should == 'pengwynn'
    end

    should 'handle arrays' do
      @stubs.get('/array') { [200, {}, "[{\"username\":\"pengwynn\"},{\"username\":\"jnunemaker\"}]" ] }
      us = @conn.get("/array").body
      us.first.username.should == 'pengwynn'
      us.last.username.should == 'jnunemaker'
    end
  end
end
