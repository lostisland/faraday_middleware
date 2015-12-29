require 'faraday'

module FaradayMiddleware
  # Public: Converts parsed response bodies to a Hashie::Rash if they were of
  # Hash or Array type.
  class Rashify < Faraday::Response::Middleware
    attr_accessor :rash_class

    class << self
      attr_accessor :rash_class
    end

    dependency do
      require 'hashie/rash'
      self.rash_class = ::Hashie::Rash
    end

    def initialize(app = nil, options = {})
      super(app)
      self.rash_class = options[:rash_class] || self.class.rash_class
    end

    def parse(body)
      case body
      when Hash
        rash_class.new(body)
      when Array
        body.map { |item| parse(item) }
      else
        body
      end
    end
  end
end

# deprecated alias
Faraday::Response::Rashify = FaradayMiddleware::Rashify
