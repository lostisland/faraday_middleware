require 'helper'
require 'faraday_middleware'
require 'faraday_middleware/request/multipart_related'

describe FaradayMiddleware::MultipartRelated do

  before do
    @conn = Faraday.new do |b|
      b.request :multipart_related
      b.request :url_encoded
      b.adapter :test do |stub|
        stub.post('/echo') do |env|
          posted_as = env[:request_headers]['Content-Type']
          [200, {'Content-Type' => posted_as}, env[:body]]
        end
      end
    end
  end
  
  def perform
    metadata = Faraday::UploadIO.new(StringIO.new("{\"title\":\"multipart_related_spec.rb\"}"), 'application/json')
    file = Faraday::UploadIO.new(__FILE__, 'text/x-ruby')
    @conn.post('/echo', [metadata, file])
  end

  it "sets the Content-Type to multipart/related with the boundary" do
    response = perform
    expect(response.headers['Content-Type']).to eq("multipart/related;boundary=#{Faraday::Request::Multipart::DEFAULT_BOUNDARY}")
  end

  it "sets the body should be a Faraday::CompositeReadIO" do
    response = perform
    expect(response.body).to be_an_instance_of(Faraday::CompositeReadIO)
  end
end
