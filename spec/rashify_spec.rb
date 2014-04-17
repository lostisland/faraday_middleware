require 'helper'
require 'faraday_middleware/response/rashify'

describe FaradayMiddleware::Rashify do
  context "when used", :type => :response do
    it "creates a Hashie::Rash from the body" do
      body = { "name" => "Erik Michaels-Ober", "username" => "sferik" }
      me = process(body).body
      expect(me.name).to eq("Erik Michaels-Ober")
      expect(me.username).to eq("sferik")
    end

    it "handles strings" do
      body = "Most amazing string EVER"
      me = process(body).body
      expect(me).to eq("Most amazing string EVER")
    end

    it "handles hashes and decamelcase the keys" do
      body = { "name" => "Erik Michaels-Ober", "userName" => "sferik" }
      me = process(body).body
      expect(me.name).to eq('Erik Michaels-Ober')
      expect(me.user_name).to eq('sferik')
    end

    it "handles arrays" do
      body = [123, 456]
      values = process(body).body
      expect(values).to eq([123, 456])
    end

    it "handles arrays of hashes" do
      body = [{ "username" => "sferik" }, { "username" => "pengwynn" }]
      us = process(body).body
      expect(us.first.username).to eq('sferik')
      expect(us.last.username).to eq('pengwynn')
    end

    it "handles mixed arrays" do
      body = [123, { "username" => "sferik" }, 456]
      values = process(body).body
      expect(values.first).to eq(123)
      expect(values.last).to eq(456)
      expect(values[1].username).to eq('sferik')
    end
  end
end
