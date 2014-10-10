require 'helper'
require 'faraday_middleware/response/mashify'

describe FaradayMiddleware::Mashify do
  MyMash = Struct.new(:body)

  context "when used", :type => :response do
    it "creates a Hashie::Mash from the body" do
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

    it "handles nested arrays of hashes" do
      body = [[{ "username" => "sferik" }, { "username" => "pengwynn" }]]
      us = process(body).body.first
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

    it "allows for use of custom Mash subclasses at the class level" do
      original_class = described_class.mash_class
      described_class.mash_class = MyMash

      begin
        me = process({}).body
        expect(me).to be_instance_of(MyMash)
      ensure
        described_class.mash_class = original_class
      end
    end
  end

  context "custom mash subclass", :type => :response do
    let(:options) { {:mash_class => MyMash} }

    it "instance level" do
      me = process({}).body
        expect(me).to be_instance_of(MyMash)
    end
  end
end
