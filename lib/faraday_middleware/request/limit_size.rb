require "faraday"

module FaradayMiddleware
  # Request middleware that limits the size of the request.
  #
  # Web servers can only accept requests of finite size. This middleware will
  # cause requests that are too large to fail at the client side, with an
  # explanatory error, instead of hitting the server with the giant request.
  #
  # Currently, it only checks the length of the query string.
  #
  # Size limit is configurable. Eg:
  # Faraday.new do |conn|
  #   conn.request :limit_size, :max_query_length => 8_000
  #   conn.adapter Faraday.default_adapter
  # end
  #
  class LimitSize < Faraday::Middleware
    attr_accessor :options

    def initialize(app = nil, options = {})
      super(app)
      self.options = options
    end

    def call(env)
      if env.url.query.to_s.length > max_query_length
        fail QueryTooLong, "length is #{env.url.query.length}, max is #{max_query_length}"
      end
      @app.call(env)
    end

    private

    def max_query_length
      # See https://github.com/macournoyer/thin/blob/v1.6.3/ext/thin_parser/thin.c#L71
      options.fetch(:max_query_length, 1024 * 10)
    end

    QueryTooLong = Class.new(StandardError)
  end

end
