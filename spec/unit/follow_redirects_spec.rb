require 'helper'
require 'faraday_middleware/response/follow_redirects'
require 'faraday'

# expose a method in Test adapter that should have been public
Faraday::Adapter::Test::Stubs.class_eval { public :new_stub }

RSpec.describe FaradayMiddleware::FollowRedirects do
  let(:middleware_options) { Hash.new }

  shared_examples_for 'a successful redirection' do |status_code|
    it 'follows the redirection for a GET request' do
      expect(connection do |stub|
        stub.get('/permanent') { [status_code, {'Location' => '/found'}, ''] }
        stub.get('/found') { [200, {'Content-Type' => 'text/plain'}, 'fin'] }
      end.get('/permanent').body).to eq 'fin'
    end

    it 'follows the redirection for a HEAD request' do
      expect(connection do |stub|
               stub.head('/permanent') { [status_code, {'Location' => '/found'}, ''] }
               stub.head('/found') { [200, {'Content-Type' => 'text/plain'}, ''] }
             end.head('/permanent').status).to eq 200
    end

    it 'follows the redirection for a OPTIONS request' do
      expect(connection do |stub|
               stub.new_stub(:options, '/permanent') { [status_code, {'Location' => '/found'}, ''] }
               stub.new_stub(:options, '/found') { [200, {'Content-Type' => 'text/plain'}, ''] }
             end.run_request(:options, '/permanent', nil, nil).status).to eq 200
    end

    it 'tolerates invalid characters in redirect location' do
      unescaped_location = '/found?action_type_map=["og.likes!%20you"]'
      escaped_location = '/found?action_type_map=[%22og.likes!%20you%22]'

      expect(connection { |stub|
        stub.get('/') { [status_code, {'Location' => unescaped_location}, ''] }
        stub.get(escaped_location) { [200, {'Content-Type' => 'text/plain'}, 'fin'] }
      }.get('/').body).to eq('fin')
    end
  end

  shared_examples_for 'a forced GET redirection' do |status_code|
    [:put, :post, :delete, :patch].each do |method|
      it "a #{method.to_s.upcase} request is converted to a GET" do
        expect(connection do |stub|
          stub.new_stub(method, '/redirect') {
            [status_code, {'Location' => '/found'}, 'elsewhere']
          }
          stub.get('/found') { |env|
            body = env[:body] and body.empty? && (body = nil)
            [200, {'Content-Type' => 'text/plain'}, body.inspect]
          }
        end.run_request(method, '/redirect', 'request data', nil).body).to eq('nil')
      end
    end
  end

  shared_examples_for 'a replayed redirection' do |status_code|
    it 'redirects with the original request headers' do
      conn = connection do |stub|
        stub.get('/redirect') {
          [status_code, {'Location' => '/found'}, '']
        }
        stub.get('/found') { |env|
          [200, {'Content-Type' => 'text/plain'}, env[:request_headers]['X-Test-Value']]
        }
      end

      response = conn.get('/redirect') { |req|
        req.headers['X-Test-Value'] = 'success'
      }

      expect(response.body).to eq('success')
    end

    [:put, :post, :delete, :patch].each do |method|
      it "replays a #{method.to_s.upcase} request" do
        expect(connection do |stub|
          stub.new_stub(method, '/redirect') { [status_code, {'Location' => '/found'}, ''] }
          stub.new_stub(method, '/found') { [200, {'Content-Type' => 'text/plain'}, 'fin'] }
        end.run_request(method, '/redirect', nil, nil).body).to eq 'fin'
      end
    end

    [:put, :post, :patch].each do |method|
      it "forwards request body for a #{method.to_s.upcase} request" do
        conn = connection do |stub|
          stub.new_stub(method, '/redirect') {
            [status_code, {'Location' => '/found'}, '']
          }
          stub.new_stub(method, '/found') { |env|
            [200, {'Content-Type' => 'text/plain'}, env[:body]]
          }
        end

        response = conn.run_request(method, '/redirect', 'original data', nil)
        expect(response.body).to eq('original data')
      end
    end
  end

  it 'returns non-redirect response results' do
    expect(connection do |stub|
      stub.get('/found') { [200, {'Content-Type' => 'text/plain'}, 'fin'] }
    end.get('/found').body).to eq 'fin'
  end

  it 'follows a single redirection' do
    expect(connection do |stub|
      stub.get('/')      { [301, {'Location' => '/found'}, ''] }
      stub.get('/found') { [200, {'Content-Type' => 'text/plain'}, 'fin'] }
    end.get('/').body).to eq 'fin'
  end

  it 'follows many redirections' do
    expect(connection do |stub|
      stub.get('/')          { [301, {'Location' => '/redirect1'}, ''] }
      stub.get('/redirect1') { [301, {'Location' => '/redirect2'}, ''] }
      stub.get('/redirect2') { [301, {'Location' => '/found'}, ''] }
      stub.get('/found')     { [200, {'Content-Type' => 'text/plain'}, 'fin'] }
    end.get('/').body).to eq 'fin'
  end

  it 'raises a FaradayMiddleware::RedirectLimitReached after 3 redirections (by default)' do
    conn = connection do |stub|
      stub.get('/')          { [301, {'Location' => '/redirect1'}, ''] }
      stub.get('/redirect1') { [301, {'Location' => '/redirect2'}, ''] }
      stub.get('/redirect2') { [301, {'Location' => '/redirect3'}, ''] }
      stub.get('/redirect3') { [301, {'Location' => '/found'}, ''] }
      stub.get('/found')     { [200, {'Content-Type' => 'text/plain'}, 'fin'] }
    end

    expect{ conn.get('/') }.to raise_error(FaradayMiddleware::RedirectLimitReached)
  end

  it 'raises a FaradayMiddleware::RedirectLimitReached after the initialized limit' do
    conn = connection(:limit => 1) do |stub|
      stub.get('/')          { [301, {'Location' => '/redirect1'}, ''] }
      stub.get('/redirect1') { [301, {'Location' => '/found'}, ''] }
      stub.get('/found')     { [200, {'Content-Type' => 'text/plain'}, 'fin'] }
    end

    expect{ conn.get('/') }.to raise_error(FaradayMiddleware::RedirectLimitReached)
  end

  it 'ignore fragments in the Location header' do
    expect(connection do |stub|
      stub.get('/')      { [301, {'Location' => '/found#fragment'}, ''] }
      stub.get('/found') { [200, {'Content-Type' => 'text/plain'}, 'fin'] }
    end.get('/').body).to eq 'fin'
  end

  described_class::REDIRECT_CODES.each do |code|
    context "for an HTTP #{code} response" do
      it 'raises a FaradayMiddleware::RedirectLimitReached when Location header is missing' do
        conn = connection do |stub|
          stub.get('/') { [code, {}, ''] }
        end

        expect{ conn.get('/') }.to raise_error(FaradayMiddleware::RedirectLimitReached)
      end
    end
  end

  context 'when clear_authorization_header option' do
    context 'is false' do
      it 'redirects with the original authorization headers' do
        conn = connection(:clear_authorization_header => false) do |stub|
          stub.get('/redirect') {
            [301, {'Location' => '/found'}, '']
          }
          stub.get('/found') { |env|
            [200, {'Content-Type' => 'text/plain'}, env[:request_headers]['Authorization']]
          }
        end
        response = conn.get('/redirect') { |req|
          req.headers['Authorization'] = 'success'
        }

        expect(response.body).to eq 'success'
      end
    end

    context 'is true' do
      context 'redirect to same host' do
        it 'redirects with the original authorization headers' do
          conn = connection do |stub|
            stub.get('http://localhost/redirect') do
              [301, {'Location' => '/found'}, '']
            end
            stub.get('http://localhost/found') do |env|
              [200, {}, env.request_headers['Authorization']]
            end
          end
          response = conn.get('http://localhost/redirect') do |req|
            req.headers['Authorization'] = 'success'
          end

          expect(response.body).to eq 'success'
        end
      end

      context 'redirect to same host with explicitly port' do
        it 'redirects with the original authorization headers' do
          conn = connection do |stub|
            stub.get('http://localhost/redirect') do
              [301, {'Location' => 'http://localhost:80/found'}, '']
            end
            stub.get('http://localhost/found') do |env|
              [200, {}, env.request_headers['Authorization']]
            end
          end
          response = conn.get('http://localhost/redirect') { |req|
            req.headers['Authorization'] = 'success'
          }

          expect(response.body).to eq 'success'
        end
      end

      context 'redirect to different scheme' do
        it 'redirects without original authorization headers' do
          conn = connection do |stub|
            stub.get('http://localhost/redirect') do
              [301, {'Location' => 'https://localhost2/found'}, '']
            end
            stub.get('https://localhost2/found') do |env|
              [200, {}, env.request_headers['Authorization']]
            end
          end
          response = conn.get('http://localhost/redirect') { |req|
            req.headers['Authorization'] = 'failed'
          }

          expect(response.body).to eq nil
        end
      end

      context 'redirect to different host' do
        it 'redirects without original authorization headers' do
          conn = connection do |stub|
            stub.get('http://localhost/redirect') do
              [301, {'Location' => 'http://localhost2/found'}, '']
            end
            stub.get('https://localhost2/found') do |env|
              [200, {}, env.request_headers['Authorization']]
            end
          end
          response = conn.get('http://localhost/redirect') { |req|
            req.headers['Authorization'] = 'failed'
          }

          expect(response.body).to eq nil
        end
      end

      context 'redirect to different port' do
        it 'redirects without original authorization headers' do
          conn = connection do |stub|
            stub.get('http://localhost:9090/redirect') do
              [301, {'Location' => 'http://localhost:9091/found'}, '']
            end
            stub.get('http://localhost:9091/found') do |env|
              [200, {}, env.request_headers['Authorization']]
            end
          end
          response = conn.get('http://localhost:9090/redirect') { |req|
            req.headers['Authorization'] = 'failed'
          }

          expect(response.body).to eq nil
        end
      end
    end
  end

  [301, 302].each do |code|
    context "for an HTTP #{code} response" do
      it_behaves_like 'a successful redirection', code

      context 'by default' do
        it_behaves_like 'a forced GET redirection', code
      end

      context 'with standards compliancy enabled' do
        let(:middleware_options) { { :standards_compliant => true } }
        it_behaves_like 'a replayed redirection', code
      end
    end
  end

  context 'for an HTTP 303 response' do
    context 'by default' do
      it_behaves_like 'a successful redirection', 303
      it_behaves_like 'a forced GET redirection', 303
    end

    context 'with standards compliancy enabled' do
      let(:middleware_options) { { :standards_compliant => true } }
      it_behaves_like 'a successful redirection', 303
      it_behaves_like 'a forced GET redirection', 303
    end
  end

  context 'for an HTTP 307 response' do
    context 'by default' do
      it_behaves_like 'a successful redirection', 307
      it_behaves_like 'a replayed redirection', 307
    end

    context 'with standards compliancy enabled' do
      let(:middleware_options) { { :standards_compliant => true } }
      it_behaves_like 'a successful redirection', 307
      it_behaves_like 'a replayed redirection', 307
    end
  end

  context 'for an HTTP 308 response' do
    context 'by default' do
      it_behaves_like 'a successful redirection', 308
      it_behaves_like 'a replayed redirection', 308
    end

    context 'with standards compliancy enabled' do
      let(:middleware_options) { { :standards_compliant => true } }
      it_behaves_like 'a successful redirection', 308
      it_behaves_like 'a replayed redirection', 308
    end
  end

  context 'with a callback' do
    it 'calls the callback' do
      from, to = nil, nil
      callback = lambda { |old, new| from, to = old[:url].path, new[:url].path }

      conn = connection(:callback => callback) do |stub|
        stub.get('/redirect') { [301, {'Location' => '/found'}, ''] }
        stub.get('/found') { [200, {'Content-Type' => 'text/plain'}, 'fin'] }
      end
      conn.get('/redirect')

      expect([from, to]).to eq ['/redirect', '/found']
    end
  end

  # checks env hash in request phase for basic validity
  class Lint < Struct.new(:app)
    def call(env)
      if env[:status] or env[:response] or env[:response_headers]
        raise "invalid request: #{env.inspect}"
      end
      if defined?(Faraday::Env) && !env.is_a?(Faraday::Env)
        raise "expected Faraday::Env, got #{env.class}"
      end

      app.call(env)
    end
  end

  private

  def connection(options = middleware_options)
    Faraday.new do |c|
      c.use described_class, options
      c.use Lint
      c.adapter :test do |stub|
        yield(stub) if block_given?
      end
    end
  end
end
