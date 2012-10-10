require 'helper'
require 'faraday_middleware/response/parse_yaml'

describe FaradayMiddleware::ParseYaml, :type => :response do
  context "no type matching" do
    it "doesn't change nil body" do
      expect(process(nil).body).to be_nil
    end

    it "returns false for empty body" do
      expect(process('').body).to be_false
    end

    it "parses yaml body" do
      response = process('a: 1')
      expect(response.body).to eq('a' => 1)
      expect(response.env[:raw_body]).to be_nil
    end
  end

  context "with preserving raw" do
    let(:options) { {:preserve_raw => true} }

    it "parses yaml body" do
      response = process('a: 1')
      expect(response.body).to eq('a' => 1)
      expect(response.env[:raw_body]).to eq('a: 1')
    end

    it "can opt out of preserving raw" do
      response = process('a: 1', nil, :preserve_raw => false)
      expect(response.env[:raw_body]).to be_nil
    end
  end

  context "with regexp type matching" do
    let(:options) { {:content_type => /\byaml$/} }

    it "parses json body of correct type" do
      response = process('a: 1', 'application/x-yaml')
      expect(response.body).to eq('a' => 1)
    end

    it "ignores json body of incorrect type" do
      response = process('a: 1', 'text/yaml-xml')
      expect(response.body).to eq('a: 1')
    end
  end

  it "chokes on invalid yaml" do
    expect{ process('{!') }.to raise_error(Faraday::Error::ParsingError)
  end
end
