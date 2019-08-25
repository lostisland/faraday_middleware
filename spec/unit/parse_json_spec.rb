require 'helper'
require 'faraday_middleware/response/parse_json'

RSpec.describe FaradayMiddleware::ParseJson, :type => :response do
  context "no type matching" do
    it "doesn't change nil body" do
      expect(process(nil).body).to be_nil
    end

    it "nullifies empty body" do
      expect(process('').body).to be_nil
    end

    it "parses json body" do
      response = process('{"a":1}')
      expect(response.body).to eq('a' => 1)
      expect(response.env[:raw_body]).to be_nil
    end
  end

  context "with preserving raw" do
    let(:options) { {:preserve_raw => true} }

    it "parses json body" do
      response = process('{"a":1}')
      expect(response.body).to eq('a' => 1)
      expect(response.env[:raw_body]).to eq('{"a":1}')
    end

    it "can opt out of preserving raw" do
      response = process('{"a":1}', nil, :preserve_raw => false)
      expect(response.env[:raw_body]).to be_nil
    end
  end

  context "with regexp type matching" do
    let(:options) { {:content_type => /\bjson$/} }

    it "parses json body of correct type" do
      response = process('{"a":1}', 'application/x-json')
      expect(response.body).to eq('a' => 1)
    end

    it "ignores json body of incorrect type" do
      response = process('{"a":1}', 'text/json-xml')
      expect(response.body).to eq('{"a":1}')
    end
  end

  context "with array type matching" do
    let(:options) { {:content_type => %w[a/b c/d]} }

    it "parses json body of correct type" do
      expect(process('{"a":1}', 'a/b').body).to be_a(Hash)
      expect(process('{"a":1}', 'c/d').body).to be_a(Hash)
    end

    it "ignores json body of incorrect type" do
      expect(process('{"a":1}', 'a/d').body).not_to be_a(Hash)
    end
  end

  it "chokes on invalid json" do
    expect{ process('{!') }.to raise_error(FaradayMiddleware::ResponseMiddleware::PARSING_ERROR)
  end

  it "includes the response on the ParsingError instance" do
    begin
      process('{') { |env| env[:response] = Faraday::Response.new }
      fail 'Parsing should have failed.'
    rescue FaradayMiddleware::ResponseMiddleware::PARSING_ERROR => err
      expect(err.response).to be_a(Faraday::Response)
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
      expect(response.body).to eq('{"a":1}')
    end

    it "ignores compatible type with bad data" do
      response = process('var a = 1', 'text/javascript')
      expect(response.body).to eq('var a = 1')
      expect(response['content-type']).to eq('text/javascript')
    end

    it "corrects compatible type and data" do
      response = process('{"a":1}', 'text/javascript')
      expect(response.body).to be_a(Hash)
      expect(response['content-type']).to eq('application/json')
    end

    it "corrects compatible type even when data starts with whitespace" do
      response = process(%( \r\n\t{"a":1}), 'text/javascript')
      expect(response.body).to be_a(Hash)
      expect(response['content-type']).to eq('application/json')
    end
  end

  context "HEAD responses" do
    it "nullifies the body if it's only one space" do
      response = process(' ')
      expect(response.body).to be_nil
    end

    it "nullifies the body if it's two spaces" do
      response = process(' ')
      expect(response.body).to be_nil
    end
  end

  context "JSON options" do
    let(:body) { '{"a": 1}' }
    let(:result) { {a: 1} }
    let(:options) do
      {
        :parser_options => {
          :symbolize_names => true
        }
      }
    end

    it "passes relevant options to JSON parse" do
      expect(::JSON).to receive(:parse)
        .with(body, options[:parser_options])
        .and_return(result)

      response = process(body)
      expect(response.body).to eq(result)
    end
  end
end
