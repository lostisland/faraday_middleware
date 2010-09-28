require 'hashie'

module Faraday
  class Response::Mashify < Response::Middleware
    def self.register_on_complete(env)
      env[:response].on_complete do |response|
        json = response[:body]
        if json.is_a?(Hash)
          response[:body] = Hashie::Mash.new(json)
        elsif json.is_a?(Array) and json.first.is_a?(Hash)
          response[:body] = json.map{|item| Hashie::Mash.new(item) }
        end
      end
    end

    def initialize(app)
      super
      @parser = nil
    end
  end
end
