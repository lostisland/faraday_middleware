require 'helper'
require 'faraday_middleware/request/method_override'

describe FaradayMiddleware::MethodOverride do

  HEADER = "X-Http-Method-Override"

  subject do
    FaradayMiddleware::MethodOverride.new(app, *options)
  end

  # A null Faraday app which returns the unmodified env.
  let(:app) { lambda { |env| env } }

  # A minimal Faraday request env for the given HTTP method.
  def env_for_method(method)
    { :method => method, :request_headers => Faraday::Utils::Headers.new }
  end

  # The after-middleware HTTP method and override header value
  # for the given request method.
  def method_and_header_for(method)
    request = subject.call(env_for_method(method))
    [request[:method], request[:request_headers][HEADER]]
  end

  # A simple test, before getting into more complicated declarative tests.
  describe "for a simple use case" do
    let(:options) { [:patch] }
    it "rewrites a PATCH request" do
      method_and_header_for(:patch).should == [:post, "PATCH"]
    end
    it "does not rewrite a GET request" do
      method_and_header_for(:get).should == [:get, nil]
    end
  end

  # Declarative mapping of whether a request method should be rewritten under a
  # given configuration.
  {
    # A normal use case.
    [:delete, :put, :patch] => {
      :delete => true,
      :get => false,
      :patch => true,
      :post => false,
      :put => true,
    },
    # Without any methods specified.
    [] => {
      :get => false,
      :post => false,
      :put => false,
    },
    # Of little value, but valid.
    [:post] => {
      :post => true,
    },
    # Configured with strings instead of symbols.
    ["patch", "PUT"] => {
      :get => false,
      :patch => true,
      :put => true,
    },
    # With methods as strings in faraday env.
    [:patch, :put] => {
      "GET" => false,
      "PATCH" => true,
      "post" => false,
      "put" => true,
    },
  }.each do |options, expectations|

    context "configured for #{options.inspect}" do

      let(:options) { options }

      expectations.each do |method, should_override|
        method_up = method.to_s.upcase
        if should_override
          it "sends #{method_up} as POST with #{method_up} in header" do
            method_and_header_for(method).should == [:post, method_up]
          end
        else
          it "sends #{method_up} unmodified with no header" do
            method_and_header_for(method).should == [method, nil]
          end
        end
      end

    end

  end

end
