require 'faraday'

module FaradayMiddleware
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
