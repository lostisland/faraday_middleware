require 'helper'
require 'faraday_middleware/response/parse_message_pack'

describe FaradayMiddleware::ParseMessagePack, :type => :response do
  context "no type matching" do
    it "doesn't change nil body" do
      expect(process(nil).body).to be_nil
    end

    it "returns false for empty body" do
      expect(process('').body).to be_false
    end

    it "parses message pack body" do
      response = process({ "a" => 1 }.to_msgpack)
      expect(response.body).to eq("a" => 1)
      expect(response.env[:raw_body]).to be_nil
    end
  end

  context "with preserving raw" do
    let(:options) { {:preserve_raw => true} }

    it "parses message pack body" do
      body = { "a" => 1 }.to_msgpack
      response = process(body)
      expect(response.body).to eq('a' => 1)
      expect(response.env[:raw_body]).to eq(body)
    end

    it "can opt out of preserving raw" do
      body = { "a" => 1 }.to_msgpack
      response = process(body, nil, :preserve_raw => false)
      expect(response.env[:raw_body]).to be_nil
    end
  end

  context "with regexp type matching" do
    let(:options) { {:content_type => /^application\/x-msgpack$/} }

    it "parses json body of correct type" do
      body = { "a" => 1 }.to_msgpack
      response = process(body, 'application/x-msgpack')
      expect(response.body).to eq('a' => 1)
    end

    it "ignores json body of incorrect type" do
      body = { "a" => 1 }.to_msgpack
      response = process(body, 'text/yaml-xml')
      expect(response.body).to eq(body)
    end
  end

  it "chokes on invalid message pack" do
    expect{ process('{!') }.to raise_error(Faraday::Error::ParsingError)
  end

end
