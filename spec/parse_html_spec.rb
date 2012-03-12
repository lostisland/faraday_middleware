require 'helper'
require 'faraday_middleware/response/parse_html'

describe FaradayMiddleware::ParseHtml, :type => :response do
  let(:html)  { <<-eohtml }
<html>
  <body>
    <div id="div_id">
      <h1>header</h1>
      <p>first</p>
      <p>second</p>
    </div>
  </body>
</html>
eohtml

  context "no type matching" do
    it "doesn't change nil body" do
      process(nil).body.should be_nil
    end

    it "nullifies empty body" do
      process('').body.should be_nil
    end

    it "parses html body" do
      response = process(html)
      response.body.html.body.div['id'].should eql('div_id')
      response.body.html.body.div.p[1].text.should eql('second')
      response.env[:raw_body].should be_nil
    end
  end

  context "with preserving raw" do
    let(:options) { {:preserve_raw => true} }

    it "parses html body" do
      response = process(html)
      response.body.html.body.div['id'].should eql('div_id')
      response.body.html.body.div.p[1].text.should eql('second')
      response.env[:raw_body].should eql(html)
    end

    it "can opt out of preserving raw" do
      response = process(html, nil, :preserve_raw => false)
      response.env[:raw_body].should be_nil
    end
  end

  context "with regexp type matching" do
    let(:options) { {:content_type => /\bhtml$/} }

    it "parses html body of correct type" do
      response = process(html, 'text/html')
      response.body.html.body.div['id'].should eql('div_id')
      response.body.html.body.div.p[1].text.should eql('second')
    end

    it "ignores html body of incorrect type" do
      process(html, 'application/xml').body.should eql(html)
    end
  end

  context "with array type matching" do
    let(:options) { {:content_type => %w[a/b c/d]} }

    it "parses html body of correct type" do
      process(html, 'a/b').body.should be_a(Nokogiri::HTML::Document)
      process(html, 'c/d').body.should be_a(Nokogiri::HTML::Document)
    end

    it "ignores html body of incorrect type" do
      process(html, 'a/d').body.should eql(html)
    end
  end

end
