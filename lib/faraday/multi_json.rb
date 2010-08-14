module Faraday
  class Response::MultiJson < Response::Middleware
    begin
      require 'multi_json'

      def self.register_on_complete(env)
        env[:response].on_complete do |finished_env|
          begin
            finished_env[:body] = MultiJson.decode(finished_env[:body])
          rescue JSON::ParserError
            finished_env[:body] = nil
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
