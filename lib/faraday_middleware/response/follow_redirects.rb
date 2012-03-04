require 'faraday'
require 'set'

module FaradayMiddleware
  class RedirectLimitReached < Faraday::Error::ClientError
    attr_reader :response

    def initialize(response)
      super "too many redirects; last one to: #{response['location']}"
      @response = response
    end
  end

  # Public: Follow HTTP 301, 302, 303, and 307 redirects for GET, PATCH, POST,
  # PUT, and DELETE requests.
  #
  # For HTTP 301, 302, and 303, the original request is transformed into a
  # GET request to the response Location.
  #
  # This middleware does not follow the HTTP specification for HTTP 302, in
  # that it follows the improper implementation used by most major web browsers
  # which forces the redirected request to become a GET request regardless of
  # the original request method.
  #
  # For HTTP 307, the original request is replayed to the response Location,
  # including original HTTP request method (GET, POST, PUT, DELETE, PATCH),
  # original headers, and original body.
  #
  # This middleware currently only works with synchronous requests; in other
  # words, it doesn't support parallelism.
  class FollowRedirects < Faraday::Middleware
    # HTTP methods for which 30x redirects can be followed
    ALLOWED_METHODS = Set.new [:get, :post, :put, :patch, :delete]
    # HTTP redirect status codes that this middleware implements
    REDIRECT_CODES  = Set.new [301, 302, 303, 307]

    # Default value for max redirects followed
    FOLLOW_LIMIT = 3

    # Public: Initialize the middleware.
    #
    # options - An options Hash (default: {}):
    #           limit - A Numeric redirect limit (default: 3)
    def initialize(app, options = {})
      super(app)
      @options = options
    end

    def call(env)
      perform_with_redirection(env, follow_limit)
    end

    private

    def transform_into_get?(response)
      307 != response.status
    end

    def perform_with_redirection(env, follows)
      request_body = env[:body]
      response = @app.call(env)

      response.on_complete do |env|
        if follow_redirect?(env, response)
          raise RedirectLimitReached, response if follows.zero?
          env = update_env(env, request_body, response)
          response = perform_with_redirection(env, follows - 1)
        end
      end
      response
    end

    def update_env(env, request_body, response)
      env[:url] += response['location']

      if transform_into_get?(response)
        env[:method] = :get
      else
        env[:body] = request_body
      end

      env
    end

    def follow_redirect?(env, response)
      ALLOWED_METHODS.include? env[:method] and
        REDIRECT_CODES.include? response.status
    end

    def follow_limit
      @options.fetch(:limit, FOLLOW_LIMIT)
    end
  end
end
