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
        elsif response_body.is_a?(Array) and response_body.first.is_a?(Hash)
          response[:body] = response_body.map{|item| ::Hashie::Mash.new(item)}
        end
      end
    end

    def initialize(app)
      super
      @parser = nil
    end
  end
end
