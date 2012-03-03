require 'helper'
require 'faraday_middleware/response/follow_redirects'
require 'faraday'

describe FaradayMiddleware::FollowRedirects do
  shared_examples_for 'a successful redirection' do |status_code|
    it "follows the redirection for a GET request" do
      connection do |stub|
        stub.get('/permanent') { [status_code, {'Location' => '/found'}, ''] }
        stub.get('/found') { [200, {'Content-Type' => 'text/plain'}, 'fin'] }
      end.get('/permanent').body.should eql 'fin'
    end

    ##
    # FIXME: The HTTP OPTIONS method interface, options, appears to have been 
    # overridden in the returned connection object to return an options hash.
    #
    %w(head).each do |method|
      it "returning the response headers for a #{method.upcase} request" do
        connection do |stub|
          stub.send(method, '/permanent') { [status_code, {'Location' => '/found'}, ''] }
        end.send(method, '/permanent').headers['Location'].should eql('/found')
      end
    end
  end

  shared_examples_for 'a forced GET redirection' do |status_code|
    %w(put post delete patch).each do |method|
      it "a #{method.upcase} request is converted to a GET" do
        connection = connection do |stub|
          stub.send(method, '/redirect') { [status_code, {'Location' => '/found'}, ''] }
          stub.get('/found') { [200, {'Content-Type' => 'text/plain'}, 'fin'] }
        end.send(method, '/redirect').body.should eql 'fin'
      end
    end
  end


  it "returns non-redirect response results" do
    connection do |stub|
      stub.get('/found') { [200, {'Content-Type' => 'text/plain'}, 'fin'] }
    end.get('/found').body.should eql 'fin'
  end

  it "follows a single redirection" do
    connection do |stub|
      stub.get('/')      { [301, {'Location' => '/found'}, ''] }
      stub.get('/found') { [200, {'Content-Type' => 'text/plain'}, 'fin'] }
    end.get('/').body.should eql 'fin'
  end

  it "follows many redirections" do
    connection do |stub|
      stub.get('/')          { [301, {'Location' => '/redirect1'}, ''] }
      stub.get('/redirect1') { [301, {'Location' => '/redirect2'}, ''] }
      stub.get('/redirect2') { [301, {'Location' => '/found'}, ''] }
      stub.get('/found')     { [200, {'Content-Type' => 'text/plain'}, 'fin'] }
    end.get('/').body.should eql 'fin'
  end

  it "raises a FaradayMiddleware::RedirectLimitReached after 3 redirections (by default)" do
    connection = connection do |stub|
      stub.get('/')          { [301, {'Location' => '/redirect1'}, ''] }
      stub.get('/redirect1') { [301, {'Location' => '/redirect2'}, ''] }
      stub.get('/redirect2') { [301, {'Location' => '/redirect3'}, ''] }
      stub.get('/redirect3') { [301, {'Location' => '/found'}, ''] }
      stub.get('/found')     { [200, {'Content-Type' => 'text/plain'}, 'fin'] }
    end

    expect { connection.get('/') }.
      to raise_error(FaradayMiddleware::RedirectLimitReached)
  end

  it "raises a FaradayMiddleware::RedirectLimitReached after the initialized limit" do
    connection = connection(:limit => 1) do |stub|
      stub.get('/')          { [301, {'Location' => '/redirect1'}, ''] }
      stub.get('/redirect1') { [301, {'Location' => '/found'}, ''] }
      stub.get('/found')     { [200, {'Content-Type' => 'text/plain'}, 'fin'] }
    end

    expect { connection.get('/') }.
      to raise_error(FaradayMiddleware::RedirectLimitReached)
  end

  context 'for an HTTP 301 response' do
    it_should_behave_like 'a successful redirection', 301
    it_should_behave_like 'a forced GET redirection', 301
  end

  context 'for an HTTP 302 response' do
    it_should_behave_like 'a successful redirection', 302
    it_should_behave_like 'a forced GET redirection', 302
  end

  context 'for an HTTP 303 response' do
    it_should_behave_like 'a successful redirection', 303
    it_should_behave_like 'a forced GET redirection', 303
  end

  context 'for an HTTP 307 response' do
    it_should_behave_like 'a successful redirection', 307

    it 'redirects with the original request headers' do
      connection = connection do |stub|
        stub.get('/redirect') { [307, {'Location' => '/found'}, ''] }
        stub.get('/found') { |env| [200, {'Content-Type' => 'text/plain'}, env[:request_headers]['X-Test-Value']] }
      end.get('/redirect', 'X-Test-Value' => 'success').body.should eql 'success'
    end

    %w(put post delete patch).each do |method|
      it "a #{method.upcase} request is replayed as a #{method.upcase} request to the new Location" do
        connection = connection do |stub|
          stub.send(method, '/redirect') { [307, {'Location' => '/found'}, ''] }
          stub.send(method, '/found') { [200, {'Content-Type' => 'text/plain'}, 'fin'] }
        end.send(method, '/redirect').body.should eql 'fin'
      end
    end

    %w(put post patch).each do |method|
      it "a #{method.upcase} request forwards the original body (data) to the new Location" do
        connection = connection do |stub|
          stub.send(method, '/redirect') { [307, {'Location' => '/found'}, ''] }
          stub.send(method, '/found') { |env| [200, {'Content-Type' => 'text/plain'}, env[:body]] }
        end.send(method, '/redirect', 'original data').body.should eql 'original data'
      end
    end
  end

  private

  def connection(options = {})
    Faraday.new do |c|
      c.use described_class, options
      c.adapter :test do |stub|
        yield(stub) if block_given?
      end
    end
  end
end
