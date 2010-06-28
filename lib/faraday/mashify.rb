module Faraday
  class Response::Mashify < Response::Middleware
    begin
      require 'hashie'

      def self.register_on_complete(env)
        env[:response].on_complete do |finished_env|
          json = finished_env[:body]
          if json.is_a?(Hash)
            finished_env[:body] = Hashie::Mash.new(json)
          elsif json.is_a?(Array)
            finished_env[:body] = json.map{|item| Hashie::Mash.new(item) }
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