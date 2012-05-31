require 'helper'
require 'faraday_middleware/response/raise_client_error'

describe FaradayMiddleware::RaiseClientError, :type => :response do
  context 'during configuration' do
    it 'should allow for a custom Mash class to be set' do
      described_class.should respond_to(:error_class)
      described_class.should respond_to(:error_class=)
    end
  end

  context 'when used' do
    before(:each) { described_class.error_class = FaradayMiddleware::RaiseClientError::ClientError }
    let(:raise_server_error) { described_class.new }

    FaradayMiddleware::RaiseClientError::HTTP_STATUS_CODES.each do |response_code, message|

      it "raises an exception when server's response code is #{response_code}" do
        lambda {
          raise_server_error.on_complete(:status => response_code)
        }.should raise_error(described_class.error_class)
      end

    end

    it 'should allow for use of custom Error subclasses at the class level' do
      class SomeRandomClientError < FaradayMiddleware::RaiseClientError::ClientError; end
      described_class.error_class = SomeRandomClientError

      lambda {
        raise_server_error.on_complete(:status => '401')
      }.should raise_error(SomeRandomClientError)
    end

    it 'should allow for use of custom Error subclasses at the instance level' do
      class SomeRandomClientError < FaradayMiddleware::RaiseClientError::ClientError; end
      raise_server_error = described_class.new(nil, :error_class => SomeRandomClientError)

      lambda {
        raise_server_error.on_complete(:status => '401')
      }.should raise_error(SomeRandomClientError)
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
        [401, {}, '']
      }

      lambda {
        connection.get('/error')
      }.should raise_error(FaradayMiddleware::RaiseClientError::ClientError)
    end
  end
end
