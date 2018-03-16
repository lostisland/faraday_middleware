require 'faraday'

module FaradayMiddleware
  # Public: Converts parsed response bodies to a Hashie::Mash if they were of
  # Hash or Array type.
  class Mashify < Faraday::Response::Middleware
    attr_accessor :mash_class

    class << self
      attr_accessor :mash_class
    end

    # Private: Disables Hashie warnings about overriding class properties
    # with json attributes.
    require 'hashie/mash'
    class Mash < Hashie::Mash
      disable_warnings

      def new(body)
        super.new(body)
      end
    end

    dependency do
      self.mash_class = ::FaradayMiddleware::Mashify::Mash
    end

    def initialize(app = nil, options = {})
      super(app)
      self.mash_class = options[:mash_class] || self.class.mash_class
    end

    def parse(body)
      case body
      when Hash
        mash_class.new(body)
      when Array
        body.map { |item| parse(item) }
      else
        body
      end
    end
  end
end

# deprecated alias
Faraday::Response::Mashify = FaradayMiddleware::Mashify
