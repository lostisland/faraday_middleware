require 'faraday'

module Faraday
  class Response::Mashify < Response::Middleware
    begin
      require 'hashie'
    rescue LoadError, NameError => error
      self.load_error = error
    end

    class << self
      attr_accessor :mash_class
    end

    self.mash_class = ::Hashie::Mash

    def on_complete(env)
      response_body = env[:body]
      env[:body] = if response_body.is_a?(Hash)
        self.class.mash_class.new(response_body)
      elsif response_body.is_a?(Array)
        response_body.map { |item| item.is_a?(Hash) ? self.class.mash_class.new(item) : item }
      end
    end
  end
end
