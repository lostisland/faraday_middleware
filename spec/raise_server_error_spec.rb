require 'helper'
require 'faraday_middleware/response/raise_server_error'

describe FaradayMiddleware::RaiseServerError, :type => :response do
  context 'during configuration' do
    it 'should allow for a custom Mash class to be set' do
      described_class.should respond_to(:error_class)
      described_class.should respond_to(:error_class=)
    end
  end

  context 'when used' do
    before(:each) { described_class.error_class = FaradayMiddleware::RaiseServerError::ServerError }
    let(:raise_server_error) { described_class.new }

    FaradayMiddleware::RaiseServerError::HTTP_STATUS_CODES.each do |response_code, message|

      it "raises an exception when server's response code is #{response_code}" do
        lambda {
          raise_server_error.on_complete(:status => response_code)
        }.should raise_error(described_class.error_class)
      end

    end

    it 'should allow for use of custom Error subclasses at the class level' do
      class SomeRandomError < FaradayMiddleware::RaiseServerError::ServerError; end
      described_class.error_class = SomeRandomError

      lambda {
        raise_server_error.on_complete(:status => '500')
      }.should raise_error(SomeRandomError)
    end

    it 'should allow for use of custom Error subclasses at the instance level' do
      class SomeRandomError < FaradayMiddleware::RaiseServerError::ServerError; end
      raise_server_error = described_class.new(nil, :error_class => SomeRandomError)

      lambda {
        raise_server_error.on_complete(:status => '500')
      }.should raise_error(SomeRandomError)
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

    it 'should raise exceptions on server errors' do
      stubs.get('/error') {
        [500, {}, '']
      }

      lambda {
        connection.get('/error')
      }.should raise_error(FaradayMiddleware::RaiseServerError::ServerError)
    end
  end
end
