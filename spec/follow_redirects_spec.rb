require 'helper'
require 'faraday_middleware/response/follow_redirects'
require 'faraday'
require 'forwardable'

describe FaradayMiddleware::FollowRedirects do
  let(:connection) {
    Faraday.new do |c|
      c.use described_class
      c.adapter :test do |stub|
        stub.get('/')        { [301, {'Location' => '/found'}, ''] }
        stub.post('/create') { [302, {'Location' => '/'}, ''] }
        stub.get('/found')   { [200, {'Content-Type' => 'text/plain'}, 'fin'] }
        stub.get('/loop')    { [302, {'Location' => '/loop'}, ''] }
        stub.get('/temp')    { [307, {'Location' => '/found'}, ''] }
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

  it "follows redirect twice" do
    post('/create').body.should eql('fin')
  end

  it "raises exception on loop" do
    expect { get('/loop') }.to raise_error(FaradayMiddleware::RedirectLimitReached)
  end
end
