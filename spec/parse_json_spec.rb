require 'helper'

describe Faraday::Response::ParseJson do
  context 'when used' do
    before do
      @stubs = Faraday::Adapter::Test::Stubs.new
      @connection = Faraday::Connection.new do |builder|
        builder.adapter :test, @stubs
        builder.use Faraday::Response::ParseJson
      end
    end

    it 'should handle a blank response' do
      @stubs.get('/empty') {[200, {'content-type' => 'application/json; charset=utf-8'}, '']}
      empty = @connection.get('/empty').body
      empty.should be_nil
    end

    it 'should handle a true response' do
      @stubs.get('/empty') {[200, {'content-type' => 'application/json; charset=utf-8'}, 'true']}
      empty = @connection.get('/empty').body
      empty.should be_true
    end

    it 'should handle a false response' do
      @stubs.get('/empty') {[200, {'content-type' => 'application/json; charset=utf-8'}, 'false']}
      empty = @connection.get('/empty').body
      empty.should be_false
    end

    it 'should handle hashes' do
      @stubs.get('/hash') {[200, {'content-type' => 'application/json; charset=utf-8'}, '{"name":"Erik Michaels-Ober","screen_name":"sferik"}']}
      me = @connection.get('/hash').body
      me.class.should == Hash
      me['name'].should == 'Erik Michaels-Ober'
      me['screen_name'].should == 'sferik'
    end

    it 'should handle arrays' do
      @stubs.get('/array/integers') {[200, {'content-type' => 'application/json; charset=utf-8'}, "[123, 456]"]}
      values = @connection.get('/array/integers').body
      values.class.should == Array
      values.first.should == 123
      values.last.should == 456
    end

    it 'should handle arrays of hashes' do
      @stubs.get('/array/hashes') {[200, {'content-type' => 'application/json; charset=utf-8'}, '[{"screen_name":"sferik"},{"screen_name":"pengwynn"}]']}
      us = @connection.get('/array/hashes').body
      us.class.should == Array
      us.first['screen_name'].should == 'sferik'
      us.last['screen_name'].should == 'pengwynn'
    end

    it 'should handle mixed arrays' do
      @stubs.get('/array/mixed') {[200, {'content-type' => 'application/json; charset=utf-8'}, '[123, {"screen_name":"sferik"}, 456]']}
      values = @connection.get('/array/mixed').body
      values.class.should == Array
      values.first.should == 123
      values.last.should == 456
      values[1]['screen_name'].should == 'sferik'
    end
  end
end
