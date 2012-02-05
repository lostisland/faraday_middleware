require 'faraday'

module FaradayMiddleware
  # Public: Uses the simple_oauth library to sign requests according the
  # OAuth protocol.
  #
  # The options for this middleware are forwarded to SimpleOAuth::Header:
  # :consumer_key, :consumer_secret, :token, :token_secret. All these
  # parameters are optional.
  #
  # The signature is added to the "Authorization" HTTP request header. If the
  # value for this header already exists, it is not overriden.
  #
  # If no Content-Type header is specified, this middleware assumes that the
  # body hash should be included in the signature parameters. Otherwise, it only
  # includes them if the Content-Type is application/x-www-form-urlencoded, as
  # required by the OAuth 1.0 specification.
  #
  # If the body is a string and the Content-Type is either unspecified or
  # application/x-www-form-urlencoded, this middleware re-parses the body
  # using Faraday::Utils.parse_nested_query and includes the result in the
  # OAuth signature parameters. Thus, this middleware can be included either
  # before *or* after UrlEncoded.
  #
  # All other types of encoding middleware should appear *before* this
  # middleware to ensure that Content-Type is set appropriately.
  class OAuth < Faraday::Middleware
    dependency 'simple_oauth'

    AUTH_HEADER = 'Authorization'.freeze

    def initialize(app, options)
      super(app)
      @options = options
    end

    def call(env)
      env[:request_headers][AUTH_HEADER] ||= oauth_header(env).to_s if sign_request?(env)
      @app.call(env)
    end

    def oauth_header(env)
      SimpleOAuth::Header.new env[:method],
                              env[:url].to_s,
                              signature_params(body_params(env)),
                              oauth_options(env)
    end

    def sign_request?(env)
      !!env[:request].fetch(:oauth, true)
    end

    def oauth_options(env)
      if extra = env[:request][:oauth] and extra.is_a? Hash and !extra.empty?
        @options.merge extra
      else
        @options
      end
    end

    def body_params(env)
      if include_body_params?(env)
        if env[:body].respond_to?(:to_str)
          # same test Faraday::Request::UrlEncoded uses to check for String
          # this should exactly reverse that middleware's work
          Faraday::Utils.parse_nested_query(env[:body])
        else
          env[:body] || {}
        end
      else
        {}
      end
    end

    def include_body_params?(env)
      # see RFC 5489, section 3.4.1.3.1 for details
      env[:request_headers]['Content-Type'].nil? || env[:request_headers]['Content-Type'] == 'application/x-www-form-urlencoded'
    end

    def signature_params(params)
      params.empty? ? params :
        params.reject {|k,v| v.respond_to?(:content_type) }
    end
  end
end

# deprecated alias
Faraday::Request::OAuth = FaradayMiddleware::OAuth
