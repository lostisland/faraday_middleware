# frozen_string_literal: true

require 'helper'
require 'faraday_middleware/gzip'

RSpec.describe FaradayMiddleware::Gzip, type: :response do
  require 'brotli'

  let(:middleware) do
    described_class.new(lambda { |env|
      Faraday::Response.new(env)
    })
  end

  context 'request' do
    it 'sets the Accept-Encoding request header' do
      env = process('').env
      expect(env[:request_headers][:accept_encoding]).to eq('gzip,deflate,br')
    end

    it 'doesnt overwrite existing Accept-Encoding request header' do
      env = process('') do |e|
        e[:request_headers][:accept_encoding] = 'zopfli'
      end.env
      expect(env[:request_headers][:accept_encoding]).to eq('zopfli')
    end
  end

  context 'response' do
    let(:uncompressed_body) do
      '<html><head><title>Rspec</title></head><body>Hello, spec!</body></html>'
    end
    let(:gzipped_body) do
      io = StringIO.new
      gz = Zlib::GzipWriter.new(io)
      gz.write(uncompressed_body)
      gz.close
      res = io.string
      res.force_encoding('BINARY') if res.respond_to?(:force_encoding)
      res
    end
    let(:deflated_body) do
      Zlib::Deflate.deflate(uncompressed_body)
    end
    let(:raw_deflated_body) do
      z = Zlib::Deflate.new(Zlib::DEFAULT_COMPRESSION, -Zlib::MAX_WBITS)
      compressed_body = z.deflate(uncompressed_body, Zlib::FINISH)
      z.close
      compressed_body
    end
    let(:brotlied_body) do
      Brotli.deflate(uncompressed_body)
    end
    let(:empty_body) do
      ''
    end

    shared_examples 'compressed response' do
      it 'uncompresses the body' do
        expect(process(body).body).to eq(uncompressed_body)
      end

      it 'sets the Content-Length' do
        expect(process(body).headers['Content-Length']).to eq(uncompressed_body.length)
      end

      it 'removes the Content-Encoding' do
        expect(process(body).headers['Content-Encoding']).to be_nil
      end
    end

    context 'gzipped response' do
      let(:body) { gzipped_body }
      let(:headers) { { 'Content-Encoding' => 'gzip', 'Content-Length' => body.length } }

      it_behaves_like 'compressed response'
    end

    context 'deflated response' do
      let(:body) { deflated_body }
      let(:headers) { { 'Content-Encoding' => 'deflate', 'Content-Length' => body.length } }

      it_behaves_like 'compressed response'
    end

    context 'raw deflated response' do
      let(:body) { raw_deflated_body }
      let(:headers) { { 'Content-Encoding' => 'deflate', 'Content-Length' => body.length } }

      it_behaves_like 'compressed response'
    end

    context 'brotlied response' do
      let(:body) { brotlied_body }
      let(:headers) { { 'Content-Encoding' => 'br', 'Content-Length' => body.length } }

      it_behaves_like 'compressed response'
    end

    context 'empty response' do
      let(:body) { empty_body }
      let(:headers) { { 'Content-Encoding' => 'gzip', 'Content-Length' => body.length } }

      it 'sets the Content-Length' do
        expect(process(body).headers['Content-Length']).to eq(empty_body.length)
      end

      it 'removes the Content-Encoding' do
        expect(process(body).headers['Content-Encoding']).to be_nil
      end
    end

    context 'identity response' do
      let(:body) { uncompressed_body }

      it 'does not modify the body' do
        expect(process(body).body).to eq(uncompressed_body)
      end
    end
  end
end
