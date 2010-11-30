require 'faraday'

module Faraday
  class Response::Mashify < Response::Middleware
    begin
      require 'hashie'
    rescue LoadError, NameError => error
      self.load_error = error
    end

    def self.register_on_complete(env)
      env[:response].on_complete do |response|
        response_body = response[:body]
        if response_body.is_a?(Hash)
          response[:body] = ::Hashie::Mash.new(response_body)
        elsif response_body.is_a?(Array)
          response[:body] = response_body.map{|item| item.is_a?(Hash) ? ::Hashie::Mash.new(item) : item}
        end
      end
    end

    def initialize(app)
      super
      @parser = nil
    end
  end
end
