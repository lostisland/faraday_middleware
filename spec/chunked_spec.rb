require 'helper'
require 'faraday_middleware/response/chunked'

describe FaradayMiddleware::Chunked, :type => :response do
  context "no transfer-encoding" do
    it "doesn't change nil body" do
      process(nil).body.should be_nil
    end

    it "doesn't change an empty body" do
      process('').body.should eql('')
    end

    it "doesn't change a normal body" do
      process('asdf').body.should eql('asdf')
    end
  end

  context "transfer-encoding gzip" do
    let(:headers) { {"transfer-encoding" => "gzip"}}

    it "doesn't change nil body" do
      process(nil).body.should be_nil
    end

    it "doesn't change an empty body" do
      process('').body.should eql('')
    end

    it "doesn't change a normal body" do
      process('asdf').body.should eql('asdf')
    end
  end

  context "transfer-encoding chunked" do
    let(:headers) { {"transfer-encoding" => "chunked"}}

    it "doesn't change nil body" do
      process(nil).body.should be_nil
    end

    it "doesn't change an empty body" do
      process('').body.should eql('')
    end

    it "parses a basic chunked body" do
      process("10\r\nasdfghjklasdfghj\r\n0\r\n").body.should eql('asdfghjklasdfghj')
    end

    it "parses a chunked body with no ending chunk" do
      process("10\r\nasdfghjklasdfghj\r\n").body.should eql('asdfghjklasdfghj')
    end

    it "parses a chunked body with no trailing CRLF on the data chunk" do
      process("10\r\nasdfghjklasdfghj0\r\n").body.should eql('asdfghjklasdfghj')
    end

    it "parses a chunked body with an extension" do
      process("10;foo=bar\r\nasdfghjklasdfghj\r\n0\r\n").body.should eql('asdfghjklasdfghj')
    end

    it "parses a chunked body with two extensions" do
      process("10;foo=bar;bar=baz\r\nasdfghjklasdfghj\r\n0\r\n").body.should eql('asdfghjklasdfghj')
    end

    it "parses a chunked body with two chunks" do
      process("8\r\nasdfghjk\r\n8\r\nlasdfghj\r\n0\r\n").body.should eql('asdfghjklasdfghj')
    end
  end

  context "transfer-encoding chunked,chunked" do
    let(:headers) { {"transfer-encoding" => "chunked,chunked"}}

    it "parses a basic chunked body" do
      process("10\r\nasdfghjklasdfghj\r\n0\r\n").body.should eql('asdfghjklasdfghj')
    end
  end
end
