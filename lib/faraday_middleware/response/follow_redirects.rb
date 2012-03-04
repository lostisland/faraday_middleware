require 'faraday'

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
  # that it follows the improper implementation currently used by all major
  # web browsers which forces the redirected request to become a GET request
  # regardless of the original request method.
  #
  # For HTTP 307, the original request is replayed to the response Location,
  # including original HTTP request method (GET, POST, PUT, DELETE, PATCH),
  # original headers, and original body.
  class FollowRedirects < Faraday::Middleware
    REDIRECTABLE_REQUEST = Set.new [:delete, :get, :patch, :post, :put]
    REDIRECTS = {
      301 => :get,
      302 => :get, # According to the spec, this should be :any, but we're disregarding that to mimic browser implementations.
      303 => :get,
      307 => :any
    }

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
      process_response(env[:body], @app.call(env), follow_limit)
    end


    private


    def method_for_response(env, response)
      forced_method = REDIRECTS[response.status]
      forced_method == :any ? env[:method] : forced_method
    end

    def process_response(body, response, follows)
      response.on_complete do |env|
        if redirectable?(env) && redirect?(response)
          raise RedirectLimitReached, response if follows.zero?
          env[:url] += response['location']
          env[:method] = method_for_response(env, response)
          env[:body] = body
          response = process_response(body, @app.call(env), follows - 1)
        end
      end
      response
    end

    def redirectable?(env)
      REDIRECTABLE_REQUEST.include? env[:method]
    end

    def redirect?(response)
      REDIRECTS.keys.include? response.status
    end

    def follow_limit
      @options.fetch(:limit, FOLLOW_LIMIT)
    end
  end
end
