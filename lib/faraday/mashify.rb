require 'faraday'

module Faraday
  class Response::Mashify < Response::Middleware
    begin
      require 'hashie'
    rescue LoadError, NameError => error
      self.load_error = error
    end

    def on_complete(env)
      response_body = env[:body]
      if response_body.is_a?(Hash)
        env[:body] = ::Hashie::Mash.new(response_body)
      elsif response_body.is_a?(Array)
        env[:body] = response_body.map{|item| item.is_a?(Hash) ? ::Hashie::Mash.new(item) : item}
      end
    end
  end
end
