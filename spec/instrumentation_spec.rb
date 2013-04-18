require 'faraday_middleware/instrumentation'

unless defined?(ActiveSupport::Notifications)
  module ActiveSupport
    class Notifications
      def self.instrument(*)
        yield
      end
    end
  end
end

describe FaradayMiddleware::Instrumentation do
  describe '#call' do
    before do
      @app = double 'app', :call => nil
      @env = Object.new
    end

    it 'tells the given instrumenter to instrument with the given name and env' do
      instrumenter = double 'instrumenter'
      instrumenter.should_receive(:instrument).with('custom.name', @env).and_yield
      FaradayMiddleware::Instrumentation.new(@app, :name => 'custom.name', :instrumenter => instrumenter).call(@env)
    end

    it 'defaults the instrumenter to ActiveSupport::Notifications and name to request.faraday' do
      ActiveSupport::Notifications.should_receive(:instrument).with('request.faraday', @env).and_yield
      FaradayMiddleware::Instrumentation.new(@app).call(@env)
    end

    it 'calls the app with the given env' do
      @app.should_receive(:call).with(@env)
      FaradayMiddleware::Instrumentation.new(@app).call(@env)
    end
  end
end