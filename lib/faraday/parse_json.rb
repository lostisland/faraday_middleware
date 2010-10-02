require 'multi_json'

module Faraday
  class Response::ParseJson < Response::Middleware
    def self.register_on_complete(env)
      env[:response].on_complete do |response|
        response[:body] = begin
          case response[:body]
          when ""
            nil
          when "true"
            true
          when "false"
            false
          else
            MultiJson.decode(response[:body])
          end
        end
      end
    end

    def initialize(app)
      super
      @parser = nil
    end
  end
end
