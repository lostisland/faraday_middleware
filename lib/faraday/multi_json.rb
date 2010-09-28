module Faraday
  class Response::MultiJson < Response::Middleware
    begin
      require 'multi_json'

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
    rescue LoadError, NameError => e
      self.load_error = e
    end

    def initialize(app)
      super
      @parser = nil
    end
  end
end
