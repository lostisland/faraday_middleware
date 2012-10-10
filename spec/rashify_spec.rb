require 'helper'
require 'faraday_middleware/response/rashify'

describe FaradayMiddleware::Rashify do

  context "when used" do
    let(:rashify) { described_class.new }

    it "creates a Hashie::Rash from the body" do
      env = { :body => { "name" => "Erik Michaels-Ober", "username" => "sferik" } }
      me  = rashify.on_complete(env)
      expect(me.class).to eq(Hashie::Rash)
    end

    it "handles strings" do
      env = { :body => "Most amazing string EVER" }
      me  = rashify.on_complete(env)
      expect(me).to eq("Most amazing string EVER")
    end

    it "handles hashes and decamelcase the keys" do
      env = { :body => { "name" => "Erik Michaels-Ober", "userName" => "sferik" } }
      me  = rashify.on_complete(env)
      expect(me.name).to eq('Erik Michaels-Ober')
      expect(me.user_name).to eq('sferik')
    end

    it "handles arrays" do
      env = { :body => [123, 456] }
      values = rashify.on_complete(env)
      expect(values.first).to eq(123)
      expect(values.last).to eq(456)
    end

    it "handles arrays of hashes" do
      env = { :body => [{ "username" => "sferik" }, { "username" => "pengwynn" }] }
      us  = rashify.on_complete(env)
      expect(us.first.username).to eq('sferik')
      expect(us.last.username).to eq('pengwynn')
    end

    it "handles mixed arrays" do
      env = { :body => [123, { "username" => "sferik" }, 456] }
      values = rashify.on_complete(env)
      expect(values.first).to eq(123)
      expect(values.last).to eq(456)
      expect(values[1].username).to eq('sferik')
    end
  end

  context "integration test" do
    let(:stubs) { Faraday::Adapter::Test::Stubs.new }
    let(:connection) do
      Faraday::Connection.new do |builder|
        builder.adapter :test, stubs
        builder.use described_class
      end
    end

    # although it is not good practice to pass a hash as the body, if we add ParseJson
    # to the middleware stack we end up testing two middlewares instead of one
    it "creates a Hash from the body" do
      stubs.get('/hash') {
        data = { 'name' => 'Erik Michaels-Ober', 'username' => 'sferik' }
        [200, {'content-type' => 'application/json; charset=utf-8'}, data]
      }
      me = connection.get('/hash').body
      expect(me.name).to eq('Erik Michaels-Ober')
      expect(me.username).to eq('sferik')
    end
  end
end
