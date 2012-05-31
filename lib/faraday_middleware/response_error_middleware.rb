require 'faraday'

module FaradayMiddleware
  # Public: Base class for handling error responses from server.
  class ResponseErrorMiddleware < Faraday::Response::Middleware

    # Base class that is extended for use by the RaiseServerError
    # and RaiseClientError middlewares
    class ServerResponseError < StandardError
      attr_accessor :env
      def initialize(message, env)
        @env = env
        super(message)
      end
    end

    attr_accessor :error_class, :status_codes

    class << self
      attr_accessor :error_class, :status_codes
    end

    def initialize(app = nil, options = {})
      super(app)
      self.error_class = options[:error_class] || self.class.error_class
      self.status_codes = self.class.status_codes
    end

    def on_complete(env)
      return unless status_codes.keys.include?(env[:status].to_i)

      raise error_class.new("#{env[:status]} #{status_codes[env[:status].to_i]}", env)
    end

  end
end