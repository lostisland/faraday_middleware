require 'helper'
require 'faraday_middleware/response/mashify'

describe FaradayMiddleware::Mashify do
  context "during configuration" do
    it "allows for a custom Mash class to be set" do
      expect(described_class).to respond_to(:mash_class)
      expect(described_class).to respond_to(:mash_class=)
    end
  end

  context "when used" do
    before(:each) { described_class.mash_class = ::Hashie::Mash }
    let(:mashify) { described_class.new }

    it "creates a Hashie::Mash from the body" do
      env = { :body => { "name" => "Erik Michaels-Ober", "username" => "sferik" } }
      me  = mashify.on_complete(env)
      expect(me.class).to eq(Hashie::Mash)
    end

    it "handles strings" do
      env = { :body => "Most amazing string EVER" }
      me  = mashify.on_complete(env)
      expect(me).to eq("Most amazing string EVER")
    end

    it "handles arrays" do
      env = { :body => [123, 456] }
      values = mashify.on_complete(env)
      expect(values.first).to eq(123)
      expect(values.last).to eq(456)
    end

    it "handles arrays of hashes" do
      env = { :body => [{ "username" => "sferik" }, { "username" => "pengwynn" }] }
      us  = mashify.on_complete(env)
      expect(us.first.username).to eq('sferik')
      expect(us.last.username).to eq('pengwynn')
    end

    it "handles nested arrays of hashes" do
      env = { :body => [[{ "username" => "sferik" }, { "username" => "pengwynn" }]] }
      us  = mashify.on_complete(env)
      expect(us.first.first.username).to eq('sferik')
      expect(us.first.last.username).to eq('pengwynn')
    end

    it "handles mixed arrays" do
      env = { :body => [123, { "username" => "sferik" }, 456] }
      values = mashify.on_complete(env)
      expect(values.first).to eq(123)
      expect(values.last).to eq(456)
      expect(values[1].username).to eq('sferik')
    end

    it "allows for use of custom Mash subclasses at the class level" do
      class MyMash < ::Hashie::Mash; end
      described_class.mash_class = MyMash

      env = { :body => { "name" => "Erik Michaels-Ober", "username" => "sferik" } }
      me  = mashify.on_complete(env)

      expect(me.class).to eq(MyMash)
    end

    it "allows for use of custom Mash subclasses at the instance level" do
      class MyMash < ::Hashie::Mash; end
      mashify = described_class.new(nil, :mash_class => MyMash)

      env = { :body => { "name" => "Erik Michaels-Ober", "username" => "sferik" } }
      me  = mashify.on_complete(env)

      expect(me.class).to eq(MyMash)
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
