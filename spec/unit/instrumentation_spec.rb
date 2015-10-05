require 'helper'
require 'faraday_middleware/instrumentation'

describe FaradayMiddleware::Instrumentation do
  let(:app) { lambda {|env| Faraday::Response.new } }
  let(:middleware) { described_class.new(app) }
  let(:events) { [] }
  let(:env) { faraday_env(:request_headers => Faraday::Utils::Headers.new) }

  def process
    response = middleware.call(env)
    response.finish(env)
    response
  end

  around do |example|
    subscriber = ActiveSupport::Notifications.subscribe "request.faraday" do |*args|
      events << ActiveSupport::Notifications::Event.new(*args)
    end

    example.run

    ActiveSupport::Notifications.unsubscribe(subscriber)
  end

  it "instruments the duration of the request" do
    process
    expect(events.first.duration).to be > 0
  end

  it "uses the env as event payload" do
    process
    expect(events.first.payload).to eq env
  end
end
