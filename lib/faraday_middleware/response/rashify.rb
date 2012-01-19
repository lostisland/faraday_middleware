require 'faraday_middleware/response/mashify'

module FaradayMiddleware
  class Rashify < Mashify
    dependency 'rash'

    self.mash_class = ::Hashie::Rash
  end
end
