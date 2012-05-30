require "time"
require "faraday"

module FaradayMiddleware
  # Parse ISO dates from response body
  class ParseIsoDates < ::Faraday::Response::Middleware
    def initialize(app, options = {})
      super(app)
    end

    def call(env)
      response = @app.call(env)
      parse_dates! response.env[:body]
      response
    end

    private

    def parse_dates!(value)
      case value
      when Hash
        value.each do |key, element|
          value[key] = parse_dates!(element)
        end
      when Array
        value.each_with_index do |element, index|
          value[index] = parse_dates!(element)
        end
      when /\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z\Z/m
        Time.parse(value)
      else
        value
      end
    end
  end
end
