require 'faraday'

module FaradayMiddleware
  class RedirectLimitReached < Faraday::Error::ClientError
    attr_reader :response

    def initialize(response)
      super "too many redirects; last one to: #{response['location']}"
      @response = response
    end
  end

  class NoRedirectLocation < Faraday::Error::ClientError
    attr_reader :response

    def initialize(response)
      super "no redirect location was supplied in the request"
      @response = response
    end
  end

  # Public: Follow HTTP 30x redirects.
  class FollowRedirects < Faraday::Middleware
    # TODO: 307 & standards-compliant 302
    REDIRECTS = [301, 302, 303, 307]
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
      process_response(@app.call(env), follow_limit)
    end

    def process_response(response, follows)
      response.on_complete do |env|
        if redirect? response
          raise RedirectLimitReached, response if follows.zero?
          env[:url] += redirect_url(response)
          env[:method] = :get
          response = process_response(@app.call(env), follows - 1)
        end
      end
      response
    end

    def redirect?(response)
      REDIRECTS.include? response.status
    end

    def follow_limit
      @options.fetch(:limit, FOLLOW_LIMIT)
    end

private 

    def redirect_url(response)
      if response['location'].nil?
        body_match = response.body.match(/<a href=\"([^>]+)\">/i)
        raise NoRedirectLocation.new(response) unless body_match
        body_match[1]
      else
        response['location']
      end
    end

  end
end
