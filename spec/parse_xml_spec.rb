require 'helper'
require 'faraday_middleware/response/parse_xml'

describe FaradayMiddleware::ParseXml, :type => :response do
  let(:xml)  { '<user><name>Erik Michaels-Ober</name><screen_name>sferik</screen_name></user>' }
  let(:user) { {'user' => {'name' => 'Erik Michaels-Ober', 'screen_name' => 'sferik'} } }

  context "no type matching" do
    it "doesn't change nil body" do
      expect(process(nil).body).to be_nil
    end

    it "turns empty body into empty hash" do
      expect(process('').body).to be_eql({})
    end

    it "parses xml body" do
      response = process(xml)
      expect(response.body).to eq(user)
      expect(response.env[:raw_body]).to be_nil
    end
  end

  context "with preserving raw" do
    let(:options) { {:preserve_raw => true} }

    it "parses xml body" do
      response = process(xml)
      expect(response.body).to eq(user)
      expect(response.env[:raw_body]).to eq(xml)
    end

    it "can opt out of preserving raw" do
      response = process(xml, nil, :preserve_raw => false)
      expect(response.env[:raw_body]).to be_nil
    end
  end

  context "with regexp type matching" do
    let(:options) { {:content_type => /\bxml$/} }

    it "parses xml body of correct type" do
      response = process(xml, 'application/xml')
      expect(response.body).to eq(user)
    end

    it "ignores xml body of incorrect type" do
      response = process(xml, 'text/html')
      expect(response.body).to eq(xml)
    end
  end

  context "with array type matching" do
    let(:options) { {:content_type => %w[a/b c/d]} }

    it "parses xml body of correct type" do
      expect(process(xml, 'a/b').body).to be_a(Hash)
      expect(process(xml, 'c/d').body).to be_a(Hash)
    end

    it "ignores xml body of incorrect type" do
      expect(process(xml, 'a/d').body).not_to be_a(Hash)
    end
  end

  it "chokes on invalid xml" do
    ['{!', '"a"', 'true', 'null', '1'].each do |data|
      expect{ process(data) }.to raise_error(Faraday::Error::ParsingError)
    end
  end
end
