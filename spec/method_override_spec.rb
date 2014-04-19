require 'helper'
require 'faraday_middleware/request/method_override'

describe FaradayMiddleware::MethodOverride do

  let(:middleware) { described_class.new(lambda {|env| env }, *options) }
  let(:env) { middleware.call faraday_env(request_env(request_method)) }

  def request_env(method)
    { :method => method,
      :request_headers => Faraday::Utils::Headers.new
    }
  end

  shared_examples "overrides method" do |method|
    it "sets physical method to POST" do
      expect(env[:method]).to eq(:post)
    end

    it "sets header to #{method}" do
      expect(env[:request_headers]['X-Http-Method-Override']).to eq(method)
    end
  end

  shared_examples "doesn't override method" do |method|
    it "keeps original method" do
      expect(env[:method]).to eq(method)
    end

    it "doesn't set header value" do
      expect(env[:request_headers]).not_to have_key('X-Http-Method-Override')
    end

  end

  context "with default options" do
    let(:options) { nil }

    context "GET" do
      let(:request_method) { :get }
      include_examples "doesn't override method", :get
    end

    context "POST" do
      let(:request_method) { :post }
      include_examples "doesn't override method", :post
    end

    context "PUT" do
      let(:request_method) { :put }
      include_examples "overrides method", 'PUT'
    end
  end

  context "configured to rewrite [:patch, :delete]" do
    let(:options) { [{ :rewrite => [:patch, :delete] }] }

    context "PUT" do
      let(:request_method) { :put }
      include_examples "doesn't override method", :put
    end

    context "PATCH" do
      let(:request_method) { :patch }
      include_examples "overrides method", 'PATCH'
    end

    context "DELETE" do
      let(:request_method) { :delete }
      include_examples "overrides method", 'DELETE'
    end
  end

  context "configured to rewrite ['PATCH']" do
    let(:options) { [{ :rewrite => %w[PATCH] }] }

    context "PATCH" do
      let(:request_method) { :patch }
      include_examples "overrides method", 'PATCH'
    end
  end

  context "with invalid option" do
    let(:options) { [{ :hello => 'world' }] }
    let(:request_method) { :get }

    it "raises key error" do
      expect{ env }.to raise_error(IndexError, /key [\s\w]*not found/)
    end
  end

end
