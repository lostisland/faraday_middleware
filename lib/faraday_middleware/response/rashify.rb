require 'faraday_middleware/response/mashify'

module FaradayMiddleware
  class Rashify < Mashify
    dependency do
      require 'rash'
      self.mash_class = ::Hashie::Rash
    end
  end
end

# deprecated alias
Faraday::Response::Rashify = FaradayMiddleware::Rashify
