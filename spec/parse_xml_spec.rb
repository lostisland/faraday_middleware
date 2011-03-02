require 'helper'

describe Faraday::Response::ParseXml do
  context 'when used' do
    before do
      @stubs = Faraday::Adapter::Test::Stubs.new
      @connection = Faraday::Connection.new do |builder|
        builder.adapter :test, @stubs
        builder.use Faraday::Response::ParseXml
      end
    end

    it 'should handle an empty response' do
      @stubs.get('/empty') {[200, {'content-type' => 'application/xml; charset=utf-8'}, '']}
      empty = @connection.get('/empty').body
      empty.should == Hash.new
    end

    it 'should create a Hash from the body' do
      @stubs.get('/hash') {[200, {'content-type' => 'application/xml; charset=utf-8'}, '<user><name>Erik Michaels-Ober</name><screen_name>sferik</screen_name></user>']}
      me = @connection.get('/hash').body
      me.class.should == Hash
    end

    it 'should handle hashes' do
      @stubs.get('/hash') {[200, {'content-type' => 'application/xml; charset=utf-8'}, '<user><name>Erik Michaels-Ober</name><screen_name>sferik</screen_name></user>']}
      me = @connection.get('/hash').body['user']
      me['name'].should == 'Erik Michaels-Ober'
      me['screen_name'].should == 'sferik'
    end
  end
end
