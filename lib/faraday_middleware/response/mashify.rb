require 'faraday'

module FaradayMiddleware
  # Public: Converts parsed response bodies to a Hashie::Mash if they were of
  # Hash or Array type.
  class Mashify < Faraday::Response::Middleware
    class << self
      attr_accessor :mash_class
    end

    dependency do
      require 'hashie/mash'
      self.mash_class = ::Hashie::Mash
    end

    def parse(body)
      case body
      when Hash
        self.class.mash_class.new(body)
      when Array
        body.map { |item| item.is_a?(Hash) ? self.class.mash_class.new(item) : item }
      else
        body
      end
    end
  end
end

# deprecated alias
Faraday::Response::Mashify = FaradayMiddleware::Mashify
