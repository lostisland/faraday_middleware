require 'helper'
require 'faraday_middleware/request/encode_xml'

describe FaradayMiddleware::EncodeXml do
  let(:middleware) { described_class.new(lambda{ |env| env }) }

  def process(body, content_type = nil)
    env = { :body => body, :request_headers => Faraday::Utils::Headers.new }
    env[:request_headers]['content-type'] = content_type if content_type
    middleware.call(faraday_env(env))
  end

  def result_body() result[:body] end
  def result_type() result[:request_headers]['content-type'] end

  context "no body" do
    let(:result) { process(nil) }

    it "doesn't change body" do
      expect(result_body).to be_nil
    end

    it "doesn't add content type" do
      expect(result_type).to be_nil
    end
  end

  context "empty body" do
    let(:result) { process('') }

    it "doesn't change body" do
      expect(result_body).to be_empty
    end

    it "doesn't add content type" do
      expect(result_type).to be_nil
    end
  end

  context "string body" do
    let(:result) { process('{"a": 1}') }

    it "doesn't change body" do
      expect(result_body).to eq('{"a": 1}')
    end

    it "adds content type" do
      expect(result_type).to eq('application/xml')
    end
  end

  context "object body" do
    let(:result) { process({:a => 1}) }

    it "encodes body" do
      expect(result_body).to eq('<a>1</a>')
    end

    it "adds content type" do
      expect(result_type).to eq('application/xml')
    end
  end

  context "nested object body" do
    let(:result) { process({:a => { :b => 1 }}) }

    it "encodes body" do
      expect(result_body).to eq('<a><b>1</b></a>')
    end

    it "adds content type" do
      expect(result_type).to eq('application/xml')
    end
  end

  context "empty object body" do
    let(:result) { process({}) }

    it "encodes body" do
      expect(result_body).to eq('')
    end
  end

  context "object body with xml type" do
    let(:result) { process({:a => 1}, 'application/xml; charset=utf-8') }

    it "encodes body" do
      expect(result_body).to eq('<a>1</a>')
    end

    it "doesn't change content type" do
      expect(result_type).to eq('application/xml; charset=utf-8')
    end
  end

  context "object body with incompatible type" do
    let(:result) { process({:a => 1}, 'application/json; charset=utf-8') }

    it "doesn't change body" do
      expect(result_body).to eq({:a => 1})
    end

    it "doesn't change content type" do
      expect(result_type).to eq('application/json; charset=utf-8')
    end
  end
end
