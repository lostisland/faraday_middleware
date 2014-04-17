require 'faraday'
require 'forwardable'

module FaradayMiddleware
  # Public: A simple middleware that adds an access token to each request.
  #
  # The token is added as both "access_token" query parameter and the
  # "Authorization" HTTP request header. However, an explicit "access_token"
  # parameter or "Authorization" header for the current request are not
  # overriden.
  #
  # Examples
  #
  #   # configure default token:
  #   OAuth2.new(app, 'abc123')
  #
  #   # configure query parameter name:
  #   OAuth2.new(app, 'abc123', :param_name => 'my_oauth_token')
  #
  #   # default token value is optional:
  #   OAuth2.new(app, :param_name => 'my_oauth_token')
  class OAuth2 < Faraday::Middleware

    PARAM_NAME  = 'access_token'.freeze
    AUTH_HEADER = 'Authorization'.freeze

    attr_reader :param_name

    extend Forwardable
    def_delegators :'Faraday::Utils', :parse_query, :build_query

    def call(env)
      params = { param_name => @token }.update query_params(env[:url])
      token = params[param_name]

      if token.respond_to?(:empty?) && !token.empty?
        env[:url].query = build_query params
        env[:request_headers][AUTH_HEADER] ||= %(Token token="#{token}")
      end

      @app.call env
    end

    def initialize(app, token = nil, options = {})
      super(app)
      options, token = token, nil if token.is_a? Hash
      @token = token && token.to_s
      @param_name = options.fetch(:param_name, PARAM_NAME).to_s
      raise ArgumentError, ":param_name can't be blank" if @param_name.empty?
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

# deprecated alias
Faraday::Request::OAuth2 = FaradayMiddleware::OAuth2
