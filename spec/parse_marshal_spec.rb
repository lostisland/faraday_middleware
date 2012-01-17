require 'helper'
require 'faraday_middleware/response/parse_marshal'

describe FaradayMiddleware::ParseMarshal do
  context 'when used' do
    let(:parse_marshal) { described_class.new }

    it 'should load a marshalled hash' do
      me = parse_marshal.on_complete(:body => "\x04\b{\x06I\"\tname\x06:\x06ETI\"\x17Erik Michaels-Ober\x06;\x00T")
      me.class.should == Hash
    end

    it 'should handle hashes' do
      me = parse_marshal.on_complete(:body => "\x04\b{\x06I\"\tname\x06:\x06ETI\"\x17Erik Michaels-Ober\x06;\x00T")
      me['name'].should == 'Erik Michaels-Ober'
    end
  end

  context 'integration test' do
    let(:stubs) { Faraday::Adapter::Test::Stubs.new }
    let(:connection) do
      Faraday::Connection.new do |builder|
        builder.adapter :test, stubs
        builder.use described_class
      end
    end

    it 'should create a Hash from the body' do
      stubs.get('/hash') {[200, {'content-type' => 'application/xml; charset=utf-8'}, "\x04\b{\x06I\"\tname\x06:\x06ETI\"\x17Erik Michaels-Ober\x06;\x00T"]}
      me = connection.get('/hash').body
      me.class.should == Hash
    end
  end
end
