require 'helper'
require 'faraday_middleware/response/parse_xml'

describe FaradayMiddleware::ParseXml, :type => :response do
  let(:xml)  { '<user><name>Erik Michaels-Ober</name><screen_name>sferik</screen_name></user>' }
  let(:user) { {'user' => {'name' => 'Erik Michaels-Ober', 'screen_name' => 'sferik'} } }

  context "no type matching" do
    it "doesn't change nil body" do
      process(nil).body.should be_nil
    end

    it "turns empty body into empty hash" do
      process('').body.should be_eql({})
    end

    it "parses xml body" do
      response = process(xml)
      response.body.should eql(user)
      response.env[:raw_body].should be_nil
    end
  end

  context "with preserving raw" do
    let(:options) { {:preserve_raw => true} }

    it "parses xml body" do
      response = process(xml)
      response.body.should eql(user)
      response.env[:raw_body].should eql(xml)
    end

    it "can opt out of preserving raw" do
      response = process(xml, nil, :preserve_raw => false)
      response.env[:raw_body].should be_nil
    end
  end

  context "with regexp type matching" do
    let(:options) { {:content_type => /\bxml$/} }

    it "parses xml body of correct type" do
      response = process(xml, 'application/xml')
      response.body.should eql(user)
    end

    it "ignores xml body of incorrect type" do
      response = process(xml, 'text/html')
      response.body.should eql(xml)
    end
  end

  context "with array type matching" do
    let(:options) { {:content_type => %w[a/b c/d]} }

    it "parses xml body of correct type" do
      process(xml, 'a/b').body.should be_a(Hash)
      process(xml, 'c/d').body.should be_a(Hash)
    end

    it "ignores xml body of incorrect type" do
      process(xml, 'a/d').body.should_not be_a(Hash)
    end
  end

  it "chokes on invalid xml" do
    ['{!', '"a"', 'true', 'null', '1'].each do |data|
      expect { process(data) }.to raise_error(Faraday::Error::ParsingError)
    end
  end
end
