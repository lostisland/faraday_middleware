require 'faraday'
require 'forwardable'

module FaradayMiddleware
  class OAuth2 < Faraday::Middleware
    dependency 'oauth2'

    extend Forwardable
    def_delegators :'Faraday::Utils', :parse_query, :build_query

    def call(env)
      params = { 'access_token' => @token }.update query_params(env[:url])
      token  = params['access_token']

      env[:url].query = build_query params
      env[:request_headers]['Authorization'] = %(Token token="#{token}")

      @app.call env
    end

    def initialize(app, *args)
      super(app)
      @token = args.shift
    end

    def query_params(url)
      if url.query.nil? or url.query.empty?
        {}
      else
        parse_query url.query
      end
    end
  end
end
