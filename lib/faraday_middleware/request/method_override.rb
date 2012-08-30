require 'faraday'

module FaradayMiddleware

  # Rewrites poorly supported HTTP request methods to a custom
  # X-Http-Method-Override header and sends the request as POST.
  #
  # This is supported by default in Rack / Rails apps via the
  # Rack::MethodOverride module.
  #
  # See: http://rack.rubyforge.org/doc/classes/Rack/MethodOverride.html
  class MethodOverride < Faraday::Middleware

    HEADER = "X-Http-Method-Override"

    def initialize(app, *methods)
      super(app)
      @methods = methods.map { |m| normalize(m) }
    end

    def call(env)
      method = normalize(env[:method])
      rewrite_env(env, method) if @methods.include?(method)
      @app.call(env)
    end

    private

    # Move the real request method to a header, send the request as HTTP POST.
    def rewrite_env(env, method)
      env[:request_headers][HEADER] = method
      env[:method] = :post
    end

    # Normalize an HTTP method (String or Symbol) to an upper-case string.
    def normalize(method)
      method.to_s.upcase
    end

  end

end
