require 'helper'
require 'faraday_middleware/request/method_override'

describe FaradayMiddleware::MethodOverride do

  subject do
    FaradayMiddleware::MethodOverride.new(
      lambda { |env| env },
      *options
    )
  end

  # A minimal Faraday request env for the given HTTP method.
  def env_for_method(method)
    { :method => method, :request_headers => Faraday::Utils::Headers.new }
  end

  # A simple test, before getting into more complicated declarative tests.
  describe "for a simple use case" do
    let(:options) { [:patch] }

    it "rewrites a PATCH request" do
      env = subject.call(env_for_method(:patch))
      env[:method].should == :post
      env[:request_headers]["X-Http-Method-Override"].should == "PATCH"
    end

    it "does not rewrite a GET request" do
      env = subject.call(env_for_method(:get))
      env[:method].should == :get
      env[:request_headers].should_not have_key("X-Http-Method-Override")
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
            env = subject.call(env_for_method(method))
            env[:method].should == :post
            env[:request_headers]["X-Http-Method-Override"].should == method_up
          end

        else

          it "sends #{method_up} unmodified with no header" do
            env = subject.call(env_for_method(method))
            env[:method].should == method
            env[:request_headers].should_not have_key("X-Http-Method-Override")
          end

        end
      end

    end

  end

end
