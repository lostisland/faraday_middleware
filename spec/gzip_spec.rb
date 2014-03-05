require 'helper'
require 'faraday_middleware/gzip'

describe FaradayMiddleware::Gzip do

  context 'request' do
    let(:middleware) { described_class.new(lambda {|env| Faraday::Response.new(env)}) }

    it 'sets the Accept-Encoding header' do
      headers = Faraday::Utils::Headers.new
      env = {:body => nil, :request_headers => headers, :response_headers => Faraday::Utils::Headers.new}
      expect { middleware.call(env) }.to change {
        headers['Accept-Encoding']
      }.to('gzip,deflate')
    end
  end

  context 'response', :type => :response do
    let(:uncompressed_body) {
      "<html><head><title>Rspec</title></head><body>Hello, spec!</body></html>"
    }

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
      let(:body) do
        f = StringIO.new
        gz = Zlib::GzipWriter.new(f)
        gz.write(uncompressed_body)
        gz.close
        res = f.string
        res.force_encoding('BINARY') if res.respond_to?(:force_encoding)
        res
      end
      let(:headers) { {'Content-Encoding' => 'gzip', 'Content-Length' => body.length} }

      it_behaves_like 'compressed response'
    end

    context 'deflated response' do
      let(:body) { Zlib::Deflate.deflate(uncompressed_body) }
      let(:headers) { {'Content-Encoding' => 'deflate', 'Content-Length' => body.length} }

      it_behaves_like 'compressed response'
    end

    context 'identity response' do
      let(:body) { uncompressed_body }

      it 'does not modify the body' do
        expect(process(body).body).to eq(uncompressed_body)
      end
    end
  end
end
