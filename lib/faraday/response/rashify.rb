require 'faraday'

module Faraday
  class Response::Rashify < Response::Mashify
    dependency 'rash'

    self.mash_class = ::Hashie::Rash
  end
end
