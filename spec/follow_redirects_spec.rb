require 'helper'
require 'faraday_middleware/response/follow_redirects'
require 'faraday'
require 'forwardable'

describe FaradayMiddleware::FollowRedirects do
  let(:connection) {

    redirect_body = '<html><head><title>Site</title></head><body><a href="/found">moved here</a></body></html>'
    Faraday.new do |c|
      c.use described_class
      c.adapter :test do |stub|
        stub.get('/')        { [301, {'Location' => '/found'}, ''] }
        stub.post('/create') { [302, {'Location' => '/'}, ''] }
        stub.get('/found')   { [200, {'Content-Type' => 'text/plain'}, 'fin'] }
        stub.get('/loop')    { [302, {'Location' => '/loop'}, ''] }
        stub.get('/temp')    { [307, {'Location' => '/found'}, ''] }
        stub.get('/no-location') {[301, {'Content-Type' => 'text/html'}, redirect_body]}
        stub.get('/no-location-or-body') {[301, {'Content-Type' => 'text/html'}, '']}
      end
    end
  }

  extend Forwardable
  def_delegators :connection, :get, :post

  it "follows redirect" do
    get('/').body.should eql('fin')
  end

  it "follows temp redirect" do
    get('/temp').body.should eql('fin')
  end

  it "uses the the link in the body for redirection" do 
    get('/no-location').body.should eql('fin')
  end

  it "follows redirect twice" do
    post('/create').body.should eql('fin')
  end

  it "raises exception on loop" do
    expect { get('/loop') }.to raise_error(FaradayMiddleware::RedirectLimitReached)
  end

  it "raises exception when there is no place to redirect to" do
    expect { get('/no-location-or-body') }.to raise_error(FaradayMiddleware::NoRedirectLocation)
  end
end
