require 'helper'
require 'faraday_middleware/response/parse_json'

describe FaradayMiddleware::ParseJson, :type => :response do
  context "no type matching" do
    it "doesn't change nil body" do
      process(nil).body.should be_nil
    end

    it "nullifies empty body" do
      process('').body.should be_nil
    end

    it "parses json body" do
      response = process('{"a":1}')
      response.body.should eql('a' => 1)
      response.env[:raw_body].should be_nil
    end
  end

  context "with preserving raw" do
    let(:options) { {:preserve_raw => true} }

    it "parses json body" do
      response = process('{"a":1}')
      response.body.should eql('a' => 1)
      response.env[:raw_body].should eql('{"a":1}')
    end

    it "can opt out of preserving raw" do
      response = process('{"a":1}', nil, :preserve_raw => false)
      response.env[:raw_body].should be_nil
    end
  end

  context "with regexp type matching" do
    let(:options) { {:content_type => /\bjson$/} }

    it "parses json body of correct type" do
      response = process('{"a":1}', 'application/x-json')
      response.body.should eql('a' => 1)
    end

    it "ignores json body of incorrect type" do
      response = process('{"a":1}', 'text/json-xml')
      response.body.should eql('{"a":1}')
    end
  end

  context "with array type matching" do
    let(:options) { {:content_type => %w[a/b c/d]} }

    it "parses json body of correct type" do
      process('{"a":1}', 'a/b').body.should be_a(Hash)
      process('{"a":1}', 'c/d').body.should be_a(Hash)
    end

    it "ignores json body of incorrect type" do
      process('{"a":1}', 'a/d').body.should_not be_a(Hash)
    end
  end

  it "chokes on invalid json" do
    ['{!', '"a"', 'true', 'null', '1'].each do |data|
      expect { process(data) }.to raise_error(Faraday::Error::ParsingError)
    end
  end

  context "with mime type fix" do
    let(:middleware) {
      app = described_class::MimeTypeFix.new(lambda {|env|
        Faraday::Response.new(env)
      }, :content_type => /^text\//)
      described_class.new(app, :content_type => 'application/json')
    }

    it "ignores completely incompatible type" do
      response = process('{"a":1}', 'application/xml')
      response.body.should eql('{"a":1}')
    end

    it "ignores compatible type with bad data" do
      response = process('var a = 1', 'text/javascript')
      response.body.should eql('var a = 1')
      response['content-type'].should eql('text/javascript')
    end

    it "corrects compatible type and data" do
      response = process('{"a":1}', 'text/javascript')
      response.body.should be_a(Hash)
      response['content-type'].should eql('application/json')
    end

    it "corrects compatible type even when data starts with whitespace" do
      response = process(%( \r\n\t{"a":1}), 'text/javascript')
      response.body.should be_a(Hash)
      response['content-type'].should eql('application/json')
    end
  end

  context "HEAD responses" do
    it "should nullify the body if it's only one space" do
      response = process(' ')
      response.body.should be_nil
    end

    it "should nullify the body if it's two spaces" do
      response = process(' ')
      response.body.should be_nil
    end
  end
end
