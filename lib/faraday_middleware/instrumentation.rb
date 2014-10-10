require 'faraday'

module FaradayMiddleware
  # Public: Instruments requests using Active Support or a given instrumenter.
  #
  # Measures time spent only for synchronous requests.
  #
  # Examples
  #
  #   ActiveSupport::Notifications.subscribe('request.faraday') do |name, starts, ends, _, env|
  #     url = env[:url]
  #     http_method = env[:method].to_s.upcase
  #     duration = ends - starts
  #     $stderr.puts '[%s] %s %s (%.3f s)' % [url.host, http_method, url.request_uri, duration]
  #   end
  class Instrumentation < Faraday::Middleware
    def initialize(app, options = {})
      super(app)
      @instrumenter = options.fetch(:instrumenter) { ActiveSupport::Notifications }
      @name = options.fetch(:name, 'request.faraday')
    end

    def call(env)
      instrumenter.instrument(name, env) do
        @app.call(env)
      end
    end

    private

    attr_reader :instrumenter, :name
  end
end
