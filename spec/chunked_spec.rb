require 'helper'
require 'faraday_middleware/response/chunked'

describe FaradayMiddleware::Chunked, :type => :response do
  context "no transfer-encoding" do
    it "doesn't change nil body" do
      expect(process(nil).body).to be_nil
    end

    it "doesn't change an empty body" do
      expect(process('').body).to eq('')
    end

    it "doesn't change a normal body" do
      expect(process('asdf').body).to eq('asdf')
    end
  end

  context "transfer-encoding gzip" do
    let(:headers) { {"transfer-encoding" => "gzip"}}

    it "doesn't change nil body" do
      expect(process(nil).body).to be_nil
    end

    it "doesn't change an empty body" do
      expect(process('').body).to eq('')
    end

    it "doesn't change a normal body" do
      expect(process('asdf').body).to eq('asdf')
    end
  end

  context "transfer-encoding chunked" do
    let(:headers) { {"transfer-encoding" => "chunked"}}

    it "doesn't change nil body" do
      expect(process(nil).body).to be_nil
    end

    it "doesn't change an empty body" do
      expect(process('').body).to eq('')
    end

    it "parses a basic chunked body" do
      expect(process("10\r\nasdfghjklasdfghj\r\n0\r\n").body).to eq('asdfghjklasdfghj')
    end

    it "parses a chunked body with no ending chunk" do
      expect(process("10\r\nasdfghjklasdfghj\r\n").body).to eq('asdfghjklasdfghj')
    end

    it "parses a chunked body with no trailing CRLF on the data chunk" do
      expect(process("10\r\nasdfghjklasdfghj0\r\n").body).to eq('asdfghjklasdfghj')
    end

    it "parses a chunked body with an extension" do
      expect(process("10;foo=bar\r\nasdfghjklasdfghj\r\n0\r\n").body).to eq('asdfghjklasdfghj')
    end

    it "parses a chunked body with two extensions" do
      expect(process("10;foo=bar;bar=baz\r\nasdfghjklasdfghj\r\n0\r\n").body).to eq('asdfghjklasdfghj')
    end

    it "parses a chunked body with two chunks" do
      expect(process("8\r\nasdfghjk\r\n8\r\nlasdfghj\r\n0\r\n").body).to eq('asdfghjklasdfghj')
    end
  end

  context "transfer-encoding chunked,chunked" do
    let(:headers) { {"transfer-encoding" => "chunked,chunked"}}

    it "parses a basic chunked body" do
      expect(process("10\r\nasdfghjklasdfghj\r\n0\r\n").body).to eq('asdfghjklasdfghj')
    end
  end
end
