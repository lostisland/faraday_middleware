require 'faraday'

module FaradayMiddleware
  # Request middleware that adds a sipmle header. Useful for
  # when you have headers that should be sent with every
  # request. Example, API's that use headers to send API keys.

  class AddHeader < Faraday::Middleware
    attr_reader :name, :value

    def initialize(app, name, value)
      super app
      @name, @value = name, value
    end

    def call(env)
      env[:request_headers][name] = value

      @app.call env
    end
  end
end
