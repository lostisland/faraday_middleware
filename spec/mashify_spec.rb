require File.expand_path('../helper', __FILE__)

describe Faraday::Response::Mashify do
  context 'during configuration' do
    it 'should allow for a custom Mash class to be set' do
      Faraday::Response::Mashify.should respond_to(:mash_class)
      Faraday::Response::Mashify.should respond_to(:mash_class=)
    end
  end

  context 'when used' do
    before do
      @stubs = Faraday::Adapter::Test::Stubs.new
      @connection = Faraday::Connection.new do |builder|
        builder.adapter :test, @stubs
        builder.use Faraday::Response::ParseJson
        builder.use Faraday::Response::Mashify
      end
      Faraday::Response::Mashify.mash_class = ::Hashie::Mash
    end

    it 'should create a Hashie::Mash from the body' do
      @stubs.get('/hash') {[200, {'content-type' => 'application/json; charset=utf-8'}, '{"name":"Erik Michaels-Ober","username":"sferik"}']}
      me = @connection.get('/hash').body
      me.class.should == Hashie::Mash
    end

    it 'should handle hashes' do
      @stubs.get('/hash') {[200, {'content-type' => 'application/json; charset=utf-8'}, '{"name":"Erik Michaels-Ober","username":"sferik"}']}
      me = @connection.get('/hash').body
      me.name.should == 'Erik Michaels-Ober'
      me.username.should == 'sferik'
    end

    it 'should handle arrays' do
      @stubs.get('/array/integers') {[200, {'content-type' => 'application/json; charset=utf-8'}, "[123, 456]"]}
      values = @connection.get('/array/integers').body
      values.first.should == 123
      values.last.should == 456
    end

    it 'should handle arrays of hashes' do
      @stubs.get('/array/hashes') {[200, {'content-type' => 'application/json; charset=utf-8'}, '[{"username":"sferik"},{"username":"pengwynn"}]']}
      us = @connection.get('/array/hashes').body
      us.first.username.should == 'sferik'
      us.last.username.should == 'pengwynn'
    end

    it 'should handle mixed arrays' do
      @stubs.get('/array/mixed') {[200, {'content-type' => 'application/json; charset=utf-8'}, '[123, {"username":"sferik"}, 456]']}
      values = @connection.get('/array/mixed').body
      values.first.should == 123
      values.last.should == 456
      values[1].username.should == 'sferik'
    end

    it 'should allow for use of custom Mash subclasses' do
      class MyMash < ::Hashie::Mash; end
      Faraday::Response::Mashify.mash_class = MyMash

      @stubs.get('/hash') {[200, {'content-type' => 'application/json; charset=utf-8'}, '{"name":"Erik Michaels-Ober","username":"sferik"}']}
      values = @connection.get('/hash').body
      values.class.should == MyMash
    end
  end
end
