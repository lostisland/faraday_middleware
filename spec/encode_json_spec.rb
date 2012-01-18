require 'helper'
require 'faraday_middleware/request/encode_json'

describe FaradayMiddleware::EncodeJson do
  let(:middleware) { described_class.new(lambda{|env| env}) }

  def process(body, content_type = nil)
    env = {:body => body, :request_headers => Faraday::Utils::Headers.new}
    env[:request_headers]['content-type'] = content_type if content_type
    middleware.call(env)
  end

  def result_body() result[:body] end
  def result_type() result[:request_headers]['content-type'] end

  context "no body" do
    let(:result) { process(nil) }

    it "doesn't change body" do
      result_body.should be_nil
    end

    it "doesn't add content type" do
      result_type.should be_nil
    end
  end

  context "empty body" do
    let(:result) { process('') }

    it "doesn't change body" do
      result_body.should be_empty
    end

    it "doesn't add content type" do
      result_type.should be_nil
    end
  end

  context "string body" do
    let(:result) { process('{"a":1}') }

    it "doesn't change body" do
      result_body.should eql('{"a":1}')
    end

    it "adds content type" do
      result_type.should eql('application/json')
    end
  end

  context "object body" do
    let(:result) { process({:a => 1}) }

    it "encodes body" do
      result_body.should eql('{"a":1}')
    end

    it "adds content type" do
      result_type.should eql('application/json')
    end
  end

  context "empty object body" do
    let(:result) { process({}) }

    it "encodes body" do
      result_body.should eql('{}')
    end
  end

  context "object body with json type" do
    let(:result) { process({:a => 1}, 'application/json; charset=utf-8') }

    it "encodes body" do
      result_body.should eql('{"a":1}')
    end

    it "doesn't change content type" do
      result_type.should eql('application/json; charset=utf-8')
    end
  end

  context "object body with incompatible type" do
    let(:result) { process({:a => 1}, 'application/xml; charset=utf-8') }

    it "doesn't change body" do
      result_body.should eql({:a => 1})
    end

    it "doesn't change content type" do
      result_type.should eql('application/xml; charset=utf-8')
    end
  end
end
