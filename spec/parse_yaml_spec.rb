require 'helper'
require 'faraday_middleware/response/parse_yaml'

describe FaradayMiddleware::ParseYaml, :type => :response do
  context "no type matching" do
    it "doesn't change nil body" do
      process(nil).body.should be_nil
    end

    it "returns false for empty body" do
      process('').body.should be_false
    end

    it "parses yaml body" do
      response = process('a: 1')
      response.body.should eql('a' => 1)
      response.env[:raw_body].should be_nil
    end
  end

  context "with preserving raw" do
    let(:options) { {:preserve_raw => true} }

    it "parses yaml body" do
      response = process('a: 1')
      response.body.should eql('a' => 1)
      response.env[:raw_body].should eql('a: 1')
    end

    it "can opt out of preserving raw" do
      response = process('a: 1', nil, :preserve_raw => false)
      response.env[:raw_body].should be_nil
    end
  end

  context "with regexp type matching" do
    let(:options) { {:content_type => /\byaml$/} }

    it "parses json body of correct type" do
      response = process('a: 1', 'application/x-yaml')
      response.body.should eql('a' => 1)
    end

    it "ignores json body of incorrect type" do
      response = process('a: 1', 'text/yaml-xml')
      response.body.should eql('a: 1')
    end
  end

  it "chokes on invalid yaml" do
    expect { process('{!') }.to raise_error(Faraday::Error::ParsingError)
  end
end
